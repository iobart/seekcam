import 'package:pigeon/pigeon.dart';
@HostApi()
abstract class BioemtricHostApi {
  void initialize();
  void readBiometric();
  void dispose();
  void result();
}
