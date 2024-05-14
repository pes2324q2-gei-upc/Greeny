import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class BadgesPage extends StatefulWidget {
  final int level;
  final int maxLevel;
  final List<Widget> badges;

  const BadgesPage(
      {Key? key,
      required this.level,
      required this.badges,
      required this.maxLevel})
      : super(key: key);

  @override
  State<BadgesPage> createState() => _BadgesPageState();
}

class _BadgesPageState extends State<BadgesPage> {
  late int level;
  late List<Widget> badges;
  late int maxlevel;

  @override
  void initState() {
    super.initState();
    level = widget.level;
    badges = widget.badges;
    maxlevel = widget.maxLevel;
  }

  void incrementLevel() {
    setState(() {
      if (level < 9 && level < maxlevel) {
        level++;
      }
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
              'assets/badges/${level}0.png',
              width: 300,
              height: 300,
              fit: BoxFit.cover,
            ),
            // dos botones con flechas hacia la izquierda y derecha para incrementar y decrementar el nivel
            // de las insignias
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_left_rounded,
                    size: 36.0,
                  ),
                  onPressed: decrementLevel,
                ),
                Text(
                  (level + 1).toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_right_rounded,
                    size: 36.0,
                  ),
                  onPressed: incrementLevel,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
