import 'package:flutter/material.dart';

/// Mixin that provides form management for StatefulWidgets.
mixin FormMixin<T extends StatefulWidget> on State<T> {
  final formKey = GlobalKey<FormState>();

  /// Validate the form.
  bool validateForm() => formKey.currentState?.validate() ?? false;

  /// Validate and call [onValid] if form is valid.
  void submitForm(VoidCallback onValid) {
    if (validateForm()) {
      onValid();
    }
  }

  /// Reset the form.
  void resetForm() => formKey.currentState?.reset();

  /// Dismiss keyboard.
  void dismissKeyboard() => FocusScope.of(context).unfocus();
}
