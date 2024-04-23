import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/translate.dart' as t;

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 220, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 220, 255, 255),
        title: Text(translate('Editar Perfil'),
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: const Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('EDITAR PERFIL'),
        ],
      )),
    );
  }
}
