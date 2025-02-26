import 'package:flutter/services.dart';

class BiometricAuthPlugin {
  static const _channel = MethodChannel('biometric_plugin');

  static Future<bool> checkBiometricSupport() async {
    try {
      return await _channel.invokeMethod('checkBiometricSupport');
    } on PlatformException catch (e) {
      throw Exception("Error checking biometric support: ${e.message}");
    }
  }

  static Future<String> register() async {
    try {
      return await _channel.invokeMethod('register');
    } on PlatformException catch (e) {
      throw Exception("Registration failed: ${e.message}");
    }
  }

  static Future<String> authenticate() async {
    try {
      return await _channel.invokeMethod('authenticate');
    } on PlatformException catch (e) {
      throw Exception("Authentication failed: ${e.message}");
    }
  }
}