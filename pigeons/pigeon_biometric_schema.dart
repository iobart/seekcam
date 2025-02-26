import 'package:pigeon/pigeon.dart';
@HostApi()
abstract class BiometricHostApi {
  void checkBiometricSupport();
  void handleRegistration();
  void handleAuthentication();
}