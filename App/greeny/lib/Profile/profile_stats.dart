import 'package:flutter/material.dart';
import 'settings.dart';

class ProfileStatsPage extends StatefulWidget {
  const ProfileStatsPage({super.key});

  @override
  State<ProfileStatsPage> createState() => _ProfileStatsPageState();
}

class _ProfileStatsPageState extends State<ProfileStatsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Profile'),
          IconButton(onPressed: showSettings, icon: const Icon(Icons.settings))
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
}
