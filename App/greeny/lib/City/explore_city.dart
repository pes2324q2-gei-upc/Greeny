import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ExploreCity extends StatelessWidget {
  final String name;
  final String path;

  ExploreCity({Key? key, required this.name, required this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 220, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 220, 255, 255),
        title: Text('$name'),
      ),
      /*body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.width * 0.9,
            //child: Text('Texto de prueba'),
            child: ModelViewer(
              debugLogging: true,
              key: Key('$name'),
              src: 'assets/neighborhoods/$path',
              //src: 'assets/neighborhoods/nhood_1.glb',
              //autoRotate: true,
              disableZoom: false,
              rotationPerSecond: "25deg",
              autoRotateDelay: 1000,
              cameraControls: true,
            ),
          ),
          // Add more widgets to the column if needed
        ],
      )*/
      body: Center(
        child: Container(
          margin: EdgeInsets.all(10.0),
          width: 600,
          height: 600,
          //Falta que desaparezca el tutorial de como rotar
          child: ModelViewer(
            debugLogging: true,
            key: Key('$name'),
            src: 'assets/neighborhoods/$path',
            autoRotate: true,
            disableZoom: true,
            disableTap: true,
            rotationPerSecond: "25deg", // Rota 30 grados por segundo
            autoRotateDelay: 1000, // Espera 1 segundos antes de rotar
            cameraControls: true, // Permite al usuario controlar la cámara (true por defecto)
          ),
        ),
      )
    );
  }
}