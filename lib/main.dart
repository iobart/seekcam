import 'package:flutter/material.dart';
import 'core/injection/injection_di.dart';
import 'features/router/app_router.dart';

Future<void> main() async {
  await injectionSetup();
  runApp( const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: '/',
    );
  }
}

