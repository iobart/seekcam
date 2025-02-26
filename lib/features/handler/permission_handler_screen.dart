import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:seekcam/features/auth/auth_screen.dart';
import 'package:seekcam/features/handler/permision_handler.dart';
@injectable
class PermissionHandlerScreen extends StatefulWidget {
  const PermissionHandlerScreen({super.key});

  @factoryMethod
  static PermissionHandlerScreen create() => const PermissionHandlerScreen();

  @override
  _PermissionHandlerScreenState createState() => _PermissionHandlerScreenState();
}

class _PermissionHandlerScreenState extends State<PermissionHandlerScreen> {
  late final PermissionHandler _permissionHandler;
  final ValueNotifier<bool> _permissionsGranted = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _permissionHandler = GetIt.instance<PermissionHandler>();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final granted = await _permissionHandler.requestPermissions();
    _permissionsGranted.value = granted;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _permissionsGranted,
      builder: (context, permissionsGranted, child) {
        return permissionsGranted ? const AuthScreen() : _buildPermissionRequestScreen();
      },
    );
  }

  Widget _buildPermissionRequestScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Permissions'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Requesting permissions...'),
            ElevatedButton(
              onPressed: _requestPermissions,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}