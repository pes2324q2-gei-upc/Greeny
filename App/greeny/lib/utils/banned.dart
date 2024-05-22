import 'package:flutter/material.dart';
import 'package:greeny/Registration/log_in.dart';
import 'package:flutter_translate/flutter_translate.dart';

class BannedScreen extends StatelessWidget {
  const BannedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              height: 200,
              child: Column(
                children: [
                  const Icon(
                    Icons.block,
                    size: 100,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    translate('You have been banned \nfor misconduct.'),
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: const Text('Exit'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LogInPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
