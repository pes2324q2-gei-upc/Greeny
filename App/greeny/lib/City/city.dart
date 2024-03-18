import 'package:flutter/material.dart';
import 'form_final.dart';

class CityPage extends StatefulWidget {
  const CityPage({super.key});

  @override
  State<CityPage> createState() => _CityPageState();
}

class _CityPageState extends State<CityPage> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('City'),
            IconButton(onPressed: play, icon: const Icon(Icons.play_arrow)),
            IconButton(onPressed: viewHistory, icon: const Icon(Icons.restore)),
            IconButton(onPressed: finalForm, icon: const Icon(Icons.pause))
          ],
        ),
      ),
    );
  }

  void play() {
    print('Playing');
  }

  void viewHistory() {
    print('Viewing history');
  }

  void finalForm() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const FormFinalPage()),
      (route) => false,
    );
  }
}
