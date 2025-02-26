package com.example.seekcam

import CameraEvents
import CameraHostApi
import android.content.Context
import android.util.DisplayMetrics
import android.util.Log
import android.util.Rational
import android.util.Size
import android.view.Surface

import android.view.ViewGroup
import androidx.annotation.OptIn
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView

import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import com.google.mlkit.vision.barcode.BarcodeScanner
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.barcode.common.Barcode
import com.google.mlkit.vision.common.InputImage
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class CameraPlugin : FlutterPlugin, ActivityAware, CameraHostApi {

    private var cameraExecutor: ExecutorService? = null
    private var cameraProvider: ProcessCameraProvider? = null
    private var previewView: PreviewView? = null
    private var context: Context? = null
    private var activity: FlutterActivity? = null
    private var barcodeScanner: BarcodeScanner? = null
    private val analysisExecutor: ExecutorService = Executors.newSingleThreadExecutor()
    private var isScanning = true
    private var eventsApi: CameraEvents? = null
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        eventsApi = CameraEvents(binding.binaryMessenger)
        CameraHostApi.setUp(binding.binaryMessenger, this)
        binding.platformViewRegistry.registerViewFactory(
            "CameraPreviewView",
            CameraPreviewViewFactory()
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        dispose()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity as FlutterActivity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromActivityForConfigChanges() = Unit
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) = Unit

    override fun initialize() {
        barcodeScanner = BarcodeScanning.getClient()
        cameraExecutor = Executors.newSingleThreadExecutor()
        isScanning = true
    }

    override fun startPreview() {
        activity?.let { act ->
            val cameraProviderFuture = ProcessCameraProvider.getInstance(act)
            cameraProviderFuture.addListener({
                try {
                    cameraProvider = cameraProviderFuture.get()
                    bindPreviewUseCases()
                } catch (e: Exception) {
                    Log.e("CameraPlugin", "Error starting camera: ${e.message}")
                }
            }, ContextCompat.getMainExecutor(act))
        } ?: Log.e("CameraPlugin", "Activity is null")
    }

    private fun bindPreviewUseCases() {
        val display = activity?.windowManager?.defaultDisplay
        val metrics = DisplayMetrics().also {
            display?.getRealMetrics(it)
        }
        val screenAspectRatio = Rational(metrics.widthPixels, metrics.heightPixels)
        val rotation = display?.rotation ?: Surface.ROTATION_0

        val preview = Preview.Builder()
            .setTargetRotation(rotation)
            .setTargetAspectRatio(screenAspectRatio.toInt())
            //      .setTargetResolution(Size(metrics.widthPixels, metrics.heightPixels))
            .build()

        // Configurar ImageAnalysis con misma rotación
        val imageAnalysis = ImageAnalysis.Builder()
            .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
            .setTargetRotation(rotation)
            .setTargetResolution(Size(metrics.widthPixels, metrics.heightPixels))
            .build()
            .also {
                it.setAnalyzer(analysisExecutor, ::analyzeImage)
            }

        val cameraSelector = CameraSelector.Builder()
            .requireLensFacing(CameraSelector.LENS_FACING_BACK)
            .build()

        try {
            cameraProvider?.unbindAll()
            preview.surfaceProvider = previewView?.surfaceProvider

            // Vincular casos de uso al lifecycle
            cameraProvider?.bindToLifecycle(
                activity as LifecycleOwner,
                cameraSelector,
                preview,
                imageAnalysis
            )
        } catch (exc: Exception) {
            Log.e("CameraPlugin", "Error al vincular casos de uso", exc)
        }
    }

    @OptIn(ExperimentalGetImage::class)
    private fun analyzeImage(imageProxy: ImageProxy) {
        if (!isScanning || imageProxy.image == null) {
            imageProxy.close()
            return
        }

        try {
            val image = InputImage.fromMediaImage(
                imageProxy.image!!,
                imageProxy.imageInfo.rotationDegrees
            )

            barcodeScanner?.process(image)
                ?.addOnCompleteListener { imageProxy.close() }
                ?.addOnSuccessListener { processBarcodes(it) }
        } catch (e: Exception) {
            imageProxy.close()
            Log.e("Camera", "Error processing image: ${e.message}")
        }
    }

    private fun processBarcodes(barcodes: List<Barcode>) {
        barcodes.firstOrNull()?.rawValue?.let { qrContent ->
            activity?.runOnUiThread {
                onQrDetected(qrContent)
                pauseScanning()
            }
        }
    }

    override fun pauseScanning() {
        isScanning = false
    }

    override fun resumeScanning() {
        isScanning = true
    }

    override fun dispose() {
        cameraProvider?.unbindAll()
        barcodeScanner?.close()
        cameraExecutor?.shutdown()
        analysisExecutor.shutdown()
        previewView = null
        isScanning = false
    }

    private fun onQrDetected(qrContent: String): String? {
        var result: String? = null
        eventsApi?.onQrDetected(qrContent) { res ->
            result = res.toString()
        }
        return result
    }
    inner class CameraPreviewViewFactory : PlatformViewFactory(StandardMessageCodec()) {
        override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
            return object : PlatformView {
                private val localPreviewView = PreviewView(context).apply {
                    layoutParams = ViewGroup.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.MATCH_PARENT
                    )
                    scaleType = PreviewView.ScaleType.FILL_CENTER
                    post {
                        previewView = this
                        startPreview()
                    }
                }

                override fun getView() = localPreviewView
                override fun dispose() {
                    previewView = null
                }
            }
        }
    }
}

