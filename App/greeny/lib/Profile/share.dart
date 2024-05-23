import 'dart:ui' as ui;
import 'dart:io';
import 'package:greeny/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/Statistics/statistics.dart';
import 'package:share_plus/share_plus.dart';

final GlobalKey _globalKey = GlobalKey();

class SharePage extends StatefulWidget {
  const SharePage({
    super.key,
    required this.level,
    required this.mastery,
    required this.name,
    required this.username,
    required this.imagePath,
  });

  final int level;
  final int mastery;
  final String name;
  final String username;
  final String imagePath;
  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  Future<Uint8List?> capturePng() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      // Crear un nuevo ImageInfo con un fondo blanco
      final int width = image.width;
      final int height = image.height;
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(
          recorder,
          Rect.fromPoints(
              Offset.zero, Offset(width.toDouble(), height.toDouble())));
      final Paint paint = Paint()
        ..color = const Color.fromARGB(255, 220, 255, 255);
      canvas.drawRect(
          Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), paint);

      // Dibujar la imagen encima del fondo blanco
      canvas.drawImage(image, Offset.zero, Paint());

      // Convertir la imagen con el fondo blanco a formato png
      final ui.Image whiteBackgroundImage =
          await recorder.endRecording().toImage(width, height);
      ByteData? byteData =
          await whiteBackgroundImage.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      if (mounted) showMessage(context, translate("Error generating image"));
      return null;
    }
  }

  void share() async {
    Uint8List? bytes = await capturePng();
    if (bytes != null) {
      try {
        // Guarda los bytes de la imagen en un archivo temporal
        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/share_image.png').create();
        await file.writeAsBytes(bytes);

        // Comparte el archivo utilizando Share.shareFiles
        await Share.shareXFiles([XFile(file.path)]);
      } catch (e) {
        if (mounted) showMessage(context, translate("Error sharing"));
      }
    }
  }

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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: RepaintBoundary(
                key: _globalKey,
                child: Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            const SizedBox(height: 100),
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 3,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(widget.imagePath),
                              ),
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
                              child:
                                  buildBadges(widget.level - 1, widget.mastery),
                            ),
                          ],
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight:
                              450, // Ajusta este valor según tus necesidades
                        ),
                        child: const StatisticsPage(
                          sharing: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: share,
            child: Text(translate('Share')),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

Widget buildBadges(int level, int mastery) {
  List<Widget> badges = []; // Lista para almacenar las medallas
  if (mastery < 3) {
    // Bucle para generar medallas basadas en el nivel
    for (int i = 0; i < level; i++) {
      badges.add(
        Positioned(
          left: i * 25.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: Image.asset(
              'assets/badges/$i$mastery.png',
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
            left: i * 25.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: Image.asset(
                'assets/badges/$i${mastery - 1}.png',
                width: 40, // Ancho deseado
                height: 40, // Alto deseado
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      }
    }
  } else {
    for (int i = 0; i < 10; i++) {
      badges.add(
        Positioned(
          left: i * 25.0, // Espacio horizontal entre las medallas
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: Image.asset(
              'assets/badges/${i}2.png',
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
