import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:seekcam/features/camera/camera_controller.dart';
import 'package:seekcam/features/router/routes.dart';
import 'package:seekcam/features/storage/secure_storage.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  late final CameraController _controller;
 late  final SecureStorage _secureStorage;
  final ValueNotifier<String?> _qrNotifier = ValueNotifier<String?>(null);
  bool _showScanButton = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = CameraController();
    _secureStorage = GetIt.instance<SecureStorage>();
    _initializeCamera();
    _setupQrListener();
  }

  Future<void> _initializeCamera() async {
    try {
      await _controller.initialize();
    } catch (e) {
      debugPrint('Error inicializando cámara: $e');
    }
  }

  void _setupQrListener() {
    _controller.qrStream.listen((qrContent) {
      if (qrContent != _qrNotifier.value) {
        _qrNotifier.value = qrContent;
        _secureStorage.write('qr_code', qrContent);
        setState(() => _showScanButton = true);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _qrNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lector QR Profesional'),
        backgroundColor: Colors.blueGrey[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.list, color: Colors.white),
            onPressed: () => Navigator.pushReplacementNamed(context, Routes.viewStoredData)
          ),
        ],
      ),
      body: _buildMainLayout(),
    );
  }

  Widget _buildMainLayout() {
    return Stack(
      children: [
        _buildCameraPreview(),
        _buildLoadingOverlay(),
        _buildErrorOverlay(),
        _buildQrContent(),
        _buildBottomControls(),
      ],
    );
  }

  Widget _buildCameraPreview() {
    return ValueListenableBuilder<bool>(
      valueListenable: _controller.isInitialized,
      builder: (context, isInitialized, _) {
        return isInitialized
            ? SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: const AndroidView(
                  viewType: 'CameraPreviewView',
                  creationParams: {},
                  creationParamsCodec: StandardMessageCodec(),
                ),
              ),
            ),
          ),
        )
            : const SizedBox.shrink();
      },
    );
  }

  Widget _buildQrContent() {
    return ValueListenableBuilder<String?>(
      valueListenable: _qrNotifier,
      builder: (context, value, _) {
        return AnimatedOpacity(
          opacity:   value != null? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Align(
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.only(top: 100),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.blueGrey[800]!.withOpacity(0.95),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                value ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomControls() {
    return AnimatedOpacity(
      opacity: _showScanButton ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: FloatingActionButton.extended(
              onPressed: _handleScanButtonPress,
              icon: const Icon(Icons.qr_code_scanner, size: 28),
              label: const Text(
                'NUEVO ESCANEO',
                style: TextStyle(fontSize: 16),
              ),
              backgroundColor: Colors.blueGrey[800]!.withOpacity(0.95),
              foregroundColor: Colors.white,
              elevation: 8,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return ValueListenableBuilder<bool>(
      valueListenable: _controller.isInitialized,
      builder: (context, isInitialized, _) {
        return isInitialized
            ? const SizedBox.shrink()
            : Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorOverlay() {
    return ValueListenableBuilder<String?>(
      valueListenable: _controller.error,
      builder: (context, error, _) {
        return error != null
            ? Container(
          color: Colors.black54,
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              error,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
            : const SizedBox.shrink();
      },
    );
  }

  void _handleScanButtonPress() {
    HapticFeedback.lightImpact();
    _controller.resumeScanning();
    _qrNotifier.value = null;
    setState(() => _showScanButton = false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _controller.dispose();
        break;
      case AppLifecycleState.resumed:
        _controller.initialize();
        break;
      default:
        break;
    }
  }
}