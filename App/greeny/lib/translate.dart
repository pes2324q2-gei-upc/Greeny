import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

void changeLanguage(BuildContext context, String language) {
  if (language == 'English') {
    changeLocale(context, 'en_US');
  } else if (language == 'Español') {
    changeLocale(context, 'es');
  } else if (language == 'Català') {
    changeLocale(context, 'ca');
  }
}

void showLanguageDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(translate('Select a language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                changeLanguage(context, 'English');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Español'),
              onTap: () {
                changeLanguage(context, 'Español');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Català'),
              onTap: () {
                changeLanguage(context, 'Català');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}
