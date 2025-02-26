import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection_di.config.dart';

GetIt locator = GetIt.instance;
@InjectableInit(
  initializerName: r'$initConfigInjection',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> injectionSetup() async{
  locator.pushNewScope();
  // Execute init config injection
  $initConfigInjection(locator);
}