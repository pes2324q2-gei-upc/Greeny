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
  String userName = '';
  String userUsername = '';
  String dateJoined = '';
  String imagePath = '';

  final usernameController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  final nameContoller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 220, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 220, 255, 255),
        title: Text(translate('Editar Perfil'),
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: CustomScrollView(
        scrollDirection: Axis.vertical,
        slivers: [
          SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(40, 50, 40, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Form(
                      key: signUpForm,
                      child: Column(
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  translate('Edit Profile'),
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ]),
                          SizedBox(
                            height: MediaQuery.of(context)
                                    .devicePixelRatio
                                    .toInt() *
                                13,
                          ),
                          TextFormField(
                            obscureText: false,
                            controller: nameContoller,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: translate('Name'),
                            ),
                            validator: nameValidator,
                            initialValue = userName,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            obscureText: false,
                            controller: usernameController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: translate('Username'),
                            ),
                            validator: usernameValidator,
                            initialValue = userName,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            obscureText: true,
                            controller: currentPasswordController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: translate('Current Password'),
                            ),
                            validator: passwordValidator,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            obscureText: true,
                            controller: newPasswordController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: translate('New Password'),
                            ),
                            validator: passwordValidator,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            obscureText: true,
                            controller: passwordConfirmController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: translate('Confirm Password'),
                            ),
                            validator: passwordConfirmValidator,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
            onPressed: updateAccount,
            child: Text(translate("Update Profile")),
          ),
          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
            onPressed: deleteAccount,
            child: Text(translate("Delete Account")),
          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  @override
  void initState() {
    getInfoUser();
    super.initState();
  }

  Future<void> getInfoUser() async {
    List<dynamic> userData = [];

    final response = await httpGet('/api/user/');

    if (response.statusCode == 200) {
      setState(() {
        userData = json.decode(response.body);
        userName = userData[0]['first_name'];
        userUsername = userData[0]['username'];
        imagePath = userData[0]['image'];
      });
    } else {
      if (mounted) {
        showMessage(context, translate("Error loading user info"));
      }
    }
  }

  String? namealidator(String? value) {
    if (value == null || value.isEmpty) {
      return translate('Please enter your name');
    }
    return null;
  }

  String? usernameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return translate('Please enter your username');
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return translate('Please enter your password');
    }
    return null;
  }

  void updateAccount() async{}

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
