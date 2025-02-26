import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';
import 'auth.dart';
@Injectable(as: Auth)
class AuthImpl extends Auth {
  final LocalAuthentication auth = LocalAuthentication();
  static const String storedPin = '1234';

  @override
  Future<bool> canCheckBiometrics() async {
    try {
      return await auth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> authenticate() async {
    try {
      return await auth.authenticate(
        localizedReason: 'Scan your fingerprint (or face) to authenticate',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  @override
  void showPinDialog(BuildContext context, VoidCallback onAuthenticated) {
    final TextEditingController pinController = TextEditingController();
    final ValueNotifier<bool> showError = ValueNotifier(false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter PIN'),
          content: ValueListenableBuilder<bool>(
            valueListenable: showError,
            builder: (context, showErrorValue, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: pinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'PIN'),
                    onSubmitted: (pin) => validatePin(pin, showError, context, onAuthenticated),
                  ),
                  if (showErrorValue)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Incorrect PIN',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => validatePin(pinController.text, showError, context, onAuthenticated),
              child: const Text('Enter'),
            ),
          ],
        );
      },
    );
  }

  @override
  void validatePin(String enteredPin, ValueNotifier<bool> showError, BuildContext context, VoidCallback onAuthenticated) {
    if (enteredPin == storedPin) {
      Navigator.pop(context);
      onAuthenticated();
    } else {
      showError.value = true;
    }
  }
}