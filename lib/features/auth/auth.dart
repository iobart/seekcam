import 'package:flutter/material.dart';

abstract class Auth {
  Future<bool> canCheckBiometrics();
  Future<bool> authenticate();
  void showPinDialog(BuildContext context, VoidCallback onAuthenticated);
  void validatePin(String enteredPin, ValueNotifier<bool> showError, BuildContext context, VoidCallback onAuthenticated);
}