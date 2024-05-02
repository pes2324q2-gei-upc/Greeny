import 'package:flutter/material.dart';

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