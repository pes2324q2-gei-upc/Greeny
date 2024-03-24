import 'package:flutter/material.dart';
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
        title: const Text('Settings'),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Settings'),
          TextButton(onPressed: logOut, child: const Text('Log Out')),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              t.showLanguageDialog(context);
            },
          )
        ],
      )),
    );
  }

  void logOut() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LogInPage()),
      (Route<dynamic> route) => false,
    );
  }
}
