
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'auth.dart';
import 'biometric_auth.dart';
@injectable
class BiometricAuth extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const BiometricAuth({super.key, required this.onAuthenticated});
  @factoryMethod
  static BiometricAuth create(Key key, VoidCallback callback) => BiometricAuth(key: key, onAuthenticated: () {  });
  @override
  _BiometricAuthState createState() => _BiometricAuthState();
}

class _BiometricAuthState extends State<BiometricAuth> {
  late final Auth _authHandler ;
  bool _canCheckBiometrics = false;
  String _authorized = 'Not Authorized';

  @override
  void initState() {
    super.initState();
    _authHandler = GetIt.instance<Auth>();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final canCheckBiometrics = await _authHandler.canCheckBiometrics();
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _authenticate() async {
    if (_canCheckBiometrics) {
      try {
        bool isBiometricSupported = await BiometricAuthPlugin.checkBiometricSupport();
        if (isBiometricSupported) {
          String registrationResult = await BiometricAuthPlugin.register();
          print('Registration successful: $registrationResult');

          String authResult = await BiometricAuthPlugin.authenticate();
          print('Authentication successful: $authResult');

          setState(() {
            _authorized = 'Authorized';
            widget.onAuthenticated();
          });
        } else {
          setState(() {
            _authorized = 'Biometric support not available';
          });
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _authorized = 'Error during authentication';
        });
      }
    } else {
      setState(() {
        _authorized = 'Cannot check biometrics';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Authentication'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_canCheckBiometrics)
              ElevatedButton(
                onPressed: _authenticate,
                child: const Text('Login with Biometrics'),
              ),
            Text('Status: $_authorized'),
          ],
        ),
      ),
    );
  }
}