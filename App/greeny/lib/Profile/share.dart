import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/Statistics/statistics.dart';

class SharePage extends StatefulWidget {
  const SharePage({
    Key? key,
    required this.level,
    required this.mastery,
  }) : super(key: key);

  final int level;
  final int mastery;
  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 220, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 220, 255, 255),
        title: Text(
          translate('Share statistics'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
          child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: [
                const Icon(Icons.emoji_events_outlined,
                    color: Color.fromARGB(255, 133, 131, 131)),
                const SizedBox(width: 5),
                Expanded(
                  child: buildBadges(widget.level - 1, widget.mastery),
                ),
              ],
            ),
          ),
          const Expanded(
            child: StatisticsPage(
              sharing: true,
            ),
          ),
        ],
      )),
    );
  }
}

Widget buildBadges(int level, int mastery) {
  List<Widget> badges = []; // Lista para almacenar las medallas

  // Bucle para generar medallas basadas en el nivel
  for (int i = 0; i < level; i++) {
    badges.add(
      Positioned(
        left: i * 25.0, // Espacio horizontal entre las medallas
        child: ClipRRect(
          borderRadius: BorderRadius.circular(60),
          child: Image.asset(
            'assets/badges/$i$mastery.png', // Cambia la imagen según corresponda
            width: 40, // Ancho deseado
            height: 40, // Alto deseado
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
  if (mastery > 0) {
    for (int i = level; i < 10; i++) {
      badges.add(
        Positioned(
          left: i * 25.0, // Espacio horizontal entre las medallas
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: Image.asset(
              'assets/badges/$i${mastery - 1}.png', // Cambia la imagen según corresponda
              width: 40, // Ancho deseado
              height: 40, // Alto deseado
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }
  }

  return SizedBox(
    height: 40, // Establece la altura deseada
    child: Stack(
      children: badges,
    ),
  );
}
