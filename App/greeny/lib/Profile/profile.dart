import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/Profile/settings.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 220, 255, 255),
      appBar: (AppBar(
        backgroundColor: const Color.fromARGB(255, 220, 255, 255),
        title: Text(translate('Profile'),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          onPressed: share,
          icon: const Icon(Icons.ios_share),
          color: const Color.fromARGB(255, 1, 167, 164),
        ),
        actions: [
          IconButton(
            onPressed: showSettings,
            icon: const Icon(Icons.settings),
            color: const Color.fromARGB(255, 1, 167, 164),
          ),
        ],
      )),
    );
  }

  void showSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  void share() {}
}
