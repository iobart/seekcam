import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:seekcam/features/handler/permision_handler.dart';

@Injectable(as: PermissionHandler)
class PermissionHandlerImpl extends PermissionHandler {
  @override
  Future<bool> requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final biometricStatus = await Permission.sensors.request();

    return cameraStatus.isGranted || biometricStatus.isGranted;
  }
}