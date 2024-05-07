import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

void showMessage(BuildContext context, String m) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(m),
      duration: const Duration(seconds: 10),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Theme.of(context).colorScheme.primary,
    ),
  );
}

String? validator(String? value, String fieldType) {
    if (value == null || value.isEmpty) {
      return translate('Please enter your $fieldType');
    }
    return null;
}