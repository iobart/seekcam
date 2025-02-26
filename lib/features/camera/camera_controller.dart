import 'dart:async';
import 'package:flutter/foundation.dart';
import 'camera_api_pigeon.dart';

class CameraController {
  final CameraHostApi _hostApi = CameraHostApi();
  final ValueNotifier<bool> isInitialized = ValueNotifier(false);
  final ValueNotifier<String?> error = ValueNotifier(null);
  final StreamController<String> _qrStreamController = StreamController.broadcast();
  bool _isScanning = true;

  Stream<String> get qrStream => _qrStreamController.stream;

  CameraController() {
    _setupListeners();
  }

  void _setupListeners() {
    CameraEvents.setUp(_QrEventHandler(this));
  }

  Future<void> initialize() async {
    try {
      await _hostApi.initialize();
      await _hostApi.startPreview();
      isInitialized.value = true;
    } catch (e) {
      error.value = 'Error inicializando cámara: ${e.toString()}';
      throw Exception(error.value);
    }
  }

  void _handleQrDetected(String content) {
    if (!_qrStreamController.isClosed && _isScanning) {
      _qrStreamController.add(content);
      _stopScanning();
    }
  }

  Future<void> _stopScanning() async {
    if (_isScanning) {
      _isScanning = false;
      await _hostApi.pauseScanning();
      debugPrint('Escaneo pausado');
    }
  }

  Future<void> resumeScanning() async {
    if (!_isScanning) {
      _isScanning = true;
      await _hostApi.resumeScanning();
      debugPrint('Escaneo reanudado');
    }
  }

  Future<void> dispose() async {
    try {
      await _stopScanning();
      await _hostApi.dispose();
      isInitialized.value = false;
      _qrStreamController.close();
    } catch (e) {
      error.value = 'Error cerrando cámara: ${e.toString()}';
    }
  }
}

class _QrEventHandler implements CameraEvents {
  final CameraController controller;

  _QrEventHandler(this.controller);

  @override
  void onQrDetected(String qrContent) {
    debugPrint('QR detectado en handler: $qrContent');
    controller._handleQrDetected(qrContent);
  }
}