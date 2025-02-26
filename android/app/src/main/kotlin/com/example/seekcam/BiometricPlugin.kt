package com.example.seekcam
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import androidx.annotation.RequiresApi
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.security.KeyPair
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.PrivateKey
import java.security.Signature
import java.security.spec.ECGenParameterSpec
import java.util.UUID
import java.util.concurrent.Executors

class BiometricPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: FragmentActivity? = null
    private var result: Result? = null
    private var toBeSignedMessage: String? = null
    private var keyName = UUID.randomUUID().toString()

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "biometric_plugin")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity as FragmentActivity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity as FragmentActivity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    @RequiresApi(Build.VERSION_CODES.M)
    override fun onMethodCall(call: MethodCall, result: Result) {
        this.result = result
        when (call.method) {
            "checkBiometricSupport" -> checkBiometricSupport()
            "register" -> handleRegistration()
            "authenticate" -> handleAuthentication()
            else -> result.notImplemented()
        }
    }

    private fun checkBiometricSupport() {
        val biometricManager = BiometricManager.from(activity!!)
        val canAuthenticate = biometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG)
        result?.success(canAuthenticate == BiometricManager.BIOMETRIC_SUCCESS)
    }

    @RequiresApi(Build.VERSION_CODES.M)
    private fun handleRegistration() {
        if (!canAuthenticateWithStrongBiometrics()) {
            result?.error("UNAVAILABLE", "Biometric authentication not available", null)
            return
        }

        try {
            val keyPair = generateKeyPair(keyName, true)
            toBeSignedMessage = Base64.encodeToString(keyPair.public.encoded, Base64.URL_SAFE) +
                    ":" + keyName + ":" + "12345"

            val signature = initSignature(keyName)
            signature?.let { showBiometricPrompt(it) }
                ?: result?.error("INIT_ERROR", "Error initializing signature", null)
        } catch (e: Exception) {
            result?.error("REGISTRATION_ERROR", e.message, null)
        }
    }

    private fun handleAuthentication() {
        if (!canAuthenticateWithStrongBiometrics()) {
            result?.error("UNAVAILABLE", "Biometric authentication not available", null)
            return
        }

        try {
            toBeSignedMessage = "$keyName:12345"
            val signature = initSignature(keyName)
            signature?.let { showBiometricPrompt(it) }
                ?: result?.error("INIT_ERROR", "Error initializing signature", null)
        } catch (e: Exception) {
            result?.error("AUTHENTICATION_ERROR", e.message, null)
        }
    }

    private fun showBiometricPrompt(signature: Signature) {
        val executor = Executors.newSingleThreadExecutor()
        val biometricPrompt = BiometricPrompt(activity!!, executor, object : BiometricPrompt.AuthenticationCallback() {
            override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                result?.error("AUTH_ERROR", "Error: $errString ($errorCode)", null)
            }

            override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                try {
                    val signatureObj = result.cryptoObject?.signature
                    signatureObj?.update(toBeSignedMessage?.toByteArray())
                    val signatureBytes = signatureObj?.sign()
                    val signatureString = Base64.encodeToString(signatureBytes, Base64.URL_SAFE)
                    this@BiometricPlugin.result?.success("$toBeSignedMessage:$signatureString")
                } catch (e: Exception) {
                    this@BiometricPlugin.result?.error("SIGNATURE_ERROR", e.message, null)
                }
            }

            override fun onAuthenticationFailed() {
                result?.error("AUTH_FAILED", "Authentication failed", null)
            }
        })

        val promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle("Biometric Authentication")
            .setSubtitle("Authenticate to continue")
            .setNegativeButtonText("Cancel")
            .build()

        biometricPrompt.authenticate(promptInfo, BiometricPrompt.CryptoObject(signature))
    }

    @RequiresApi(Build.VERSION_CODES.M)
    @Throws(Exception::class)
    private fun generateKeyPair(keyName: String, invalidatedByBiometricEnrollment: Boolean): KeyPair {
        val keyPairGenerator = KeyPairGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_EC,
            "AndroidKeyStore"
        )

        val builder = KeyGenParameterSpec.Builder(
            keyName,
            KeyProperties.PURPOSE_SIGN
        ).apply {
            setAlgorithmParameterSpec(ECGenParameterSpec("secp256r1"))
            setDigests(
                KeyProperties.DIGEST_SHA256,
                KeyProperties.DIGEST_SHA384,
                KeyProperties.DIGEST_SHA512
            )
            setUserAuthenticationRequired(true)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                setInvalidatedByBiometricEnrollment(invalidatedByBiometricEnrollment)
            }
        }

        keyPairGenerator.initialize(builder.build())
        return keyPairGenerator.generateKeyPair()
    }

    @Throws(Exception::class)
    private fun getKeyPair(keyName: String): KeyPair? {
        val keyStore = KeyStore.getInstance("AndroidKeyStore").apply {
            load(null)
        }

        return if (keyStore.containsAlias(keyName)) {
            val publicKey = keyStore.getCertificate(keyName).publicKey
            val privateKey = keyStore.getKey(keyName, null) as PrivateKey
            KeyPair(publicKey, privateKey)
        } else {
            null
        }
    }

    @Throws(Exception::class)
    private fun initSignature(keyName: String): Signature? {
        return getKeyPair(keyName)?.let { keyPair ->
            Signature.getInstance("SHA256withECDSA").apply {
                initSign(keyPair.private)
            }
        }
    }

    private fun canAuthenticateWithStrongBiometrics(): Boolean {
        return BiometricManager.from(activity!!)
            .canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG) == BiometricManager.BIOMETRIC_SUCCESS
    }
}