import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class BadgesPage extends StatefulWidget {
  final int level;

  const BadgesPage({Key? key, required this.level}) : super(key: key);

  @override
  State<BadgesPage> createState() => _BadgesPageState();
}

class _BadgesPageState extends State<BadgesPage> {
  int level = 0;

  void incrementLevel() {
    setState(() {
      level++;
    });
  }

  void decrementLevel() {
    setState(() {
      if (level > 0) {
        level--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 220, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 220, 255, 255),
        title: Text(
          translate('Badges'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Image.asset(
              'assets/badges/nou-barris-bronze.png',
              width: 300,
              height: 300,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }
}
