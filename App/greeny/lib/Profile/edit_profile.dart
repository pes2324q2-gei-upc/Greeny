import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/user_auth.dart';
import 'package:greeny/Registration/log_in.dart';
import 'package:greeny/utils/utils.dart';

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
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: deleteAccount,
            child: Text(translate("Delete Account")),
          ),
        ],
      )),
    );
  }

  void deleteAccount() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate('Confirm Delete')),
          content:
              Text(translate('Are you sure you want to delete your account?')),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: Text(translate('Cancel')),
            ),
            TextButton(
              onPressed: () async {
                // Eliminar la cuenta si el usuario confirma
                bool esborrat = await UserAuth().userDelete();
                if (esborrat) {
                  Navigator.pushAndRemoveUntil(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(builder: (context) => const LogInPage()),
                    (Route<dynamic> route) => false,
                  );
                } else {
                  if (mounted) {
                    // ignore: use_build_context_synchronously
                    showMessage(context, translate('Error deleting account'));
                  }
                }
              },
              child: Text(translate('Delete')),
            ),
          ],
        );
      },
    );
  }
}
