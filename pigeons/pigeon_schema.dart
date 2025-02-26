import 'package:pigeon/pigeon.dart';

@HostApi()
abstract class CameraHostApi {
  void initialize();
  void startPreview();
  void dispose();
  void pauseScanning();
  void resumeScanning();
}

@FlutterApi()
abstract class CameraEvents {
  void onQrDetected(String qrContent);
}