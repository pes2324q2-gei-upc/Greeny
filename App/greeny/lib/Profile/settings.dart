import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/user_auth.dart';
import 'package:greeny/Registration/log_in.dart';
import 'package:greeny/translate.dart' as t;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 220, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 220, 255, 255),
        title: Text(translate('Settings'),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              t.showLanguageDialog(context);
            },
          )
        ],
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(onPressed: logOut, child: Text(translate('Log Out'))),
          TextButton(
              onPressed: deleteAccount,
              child: Text(translate('Delete Account'))),
        ],
      )),
    );
  }

  void logOut() async {
    await UserAuth().userLogout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LogInPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void deleteAccount() async {
    bool esborrat = await UserAuth().userDelete();
    if (mounted && esborrat) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LogInPage()),
        (Route<dynamic> route) => false,
      );
    } else {
      showMessage('Error deleting account');
    }
  }

  void showMessage(String m) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translate(m)),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }
}
