import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/Statistics/statistics.dart';

class SharePage extends StatefulWidget {
  const SharePage({
    Key? key,
    required this.level,
    required this.mastery,
    required this.name,
    required this.username,
    required this.imagePath,
  }) : super(key: key);

  final int level;
  final int mastery;
  final String name;
  final String username;
  final String imagePath;
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
      body: SingleChildScrollView(
        child: Center(
            child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape:
                          BoxShape.circle, // Establece la forma como un círculo
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey
                              .withOpacity(0.5), // Color de la sombra
                          spreadRadius: 3, // Extensión de la sombra
                          blurRadius: 3, // Desenfoque de la sombra
                          offset:
                              const Offset(0, 2), // Desplazamiento de la sombra
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                        backgroundImage: NetworkImage(widget.imagePath)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '@${widget.username}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 133, 131, 131),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 450, // Ajusta este valor según tus necesidades
              ),
              child: const StatisticsPage(
                sharing: true,
              ),
            ),
            ElevatedButton(
              onPressed: share,
              child: Text(translate('Share')),
            ),
          ],
        )),
      ),
    );
  }
}

void share() {
  // Compartir estadísticas
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
