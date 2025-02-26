import 'package:flutter/material.dart';
import 'package:seekcam/features/auth/biometric_auth_page.dart';
import 'package:seekcam/features/camera/camera_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isAuthenticated = false;

  void _onAuthenticated() {
    setState(() {
      _isAuthenticated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isAuthenticated
        ? const CameraScreen()
        : BiometricAuth(onAuthenticated: _onAuthenticated);
  }
}