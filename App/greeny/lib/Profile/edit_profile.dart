import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/user_auth.dart';
import 'package:greeny/Registration/log_in.dart';
import 'package:greeny/utils/utils.dart';
import 'package:greeny/API/requests.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String imagePath = '';
  String oldName = '';
  String oldUsername = '';
  File? _pickedImage;
  String defaultImage = '';
  bool isGoogle = false;

  final updateProfileForm = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (imagePath == '') {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 220, 255, 255),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 220, 255, 255),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 220, 255, 255),
          title: Text(translate('Edit Profile'),
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: CustomScrollView(
          scrollDirection: Axis.vertical,
          slivers: [
            SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Form(
                        key: updateProfileForm,
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                const SizedBox(
                                  height:
                                      20, // Espacio entre la imagen y la tarjeta
                                ),
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape
                                        .circle, // Establece la forma como un círculo
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(
                                            0.5), // Color de la sombra
                                        spreadRadius:
                                            3, // Extensión de la sombra
                                        blurRadius:
                                            3, // Desenfoque de la sombra
                                        offset: const Offset(0,
                                            2), // Desplazamiento de la sombra
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                      backgroundImage: imageProvider),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        color: const Color.fromARGB(
                                            255, 1, 167, 164)),
                                    child: IconButton(
                                      onPressed: showImagePickerDialog,
                                      icon: const Icon(
                                        Icons.add_a_photo,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            TextFormField(
                              obscureText: false,
                              controller: nameController,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: translate('Name'),
                              ),
                              validator: (value) => validator(value, 'name'),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              obscureText: false,
                              controller: usernameController,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: translate('Username'),
                              ),
                              validator: (value) =>
                                  validator(value, 'username'),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            renderPassword(),
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
  }

  Widget renderPassword() {
    if (isGoogle) {
      return const SizedBox();
    } else {
      return Column(
        children: [
          Text(translate(
              'To change your password, fill in the following fields:')),
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
            validator: passwordConfirmValidator,
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
            validator: passwordConfirmValidator,
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
        ],
      );
    }
  }

  ImageProvider<Object> get imageProvider {
    if (_pickedImage != null) {
      return FileImage(_pickedImage!);
    } else {
      return NetworkImage(imagePath);
    }
  }

  void showImagePickerDialog() {
    backendURL = getBackendURL();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate('Select an image')),
          content: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              crossAxisSpacing: 20, // Add horizontal spacing
              mainAxisSpacing: 20,
              children: <Widget>[
                for (int i = 1; i <= 5; i++)
                  GestureDetector(
                    onTap: () => setState(() {
                      _pickedImage = null;
                      defaultImage = 'Default$i.png';
                      imagePath =
                          'http://$backendURL/media/imatges/Default$i.png';
                      Navigator.pop(context);
                    }),
                    child: Image.network(
                        'http://$backendURL/media/imatges/Default$i.png'),
                  ),
                ElevatedButton(
                  onPressed: pickImage,
                  child: const Icon(
                    Icons.add_a_photo,
                    color: Color.fromARGB(255, 1, 167, 164),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    getInfoUser();
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    usernameController.dispose();
    newPasswordController.dispose();
    passwordConfirmController.dispose();
    currentPasswordController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (mounted) Navigator.pop(context);
      setState(() {
        _pickedImage = File(image.path);
      });
    } else {
      //if (mounted) showMessage(context, translate('No image selected.'));
    }
  }

  Future<void> getInfoUser() async {
    List<dynamic> userData = [];

    final response = await httpGet('/api/user/');

    if (response.statusCode == 200) {
      setState(() {
        userData = jsonDecode(utf8.decode(response.bodyBytes));
        imagePath = userData[0]['image'];
        oldName = userData[0]['first_name'];
        oldUsername = userData[0]['username'];
        nameController.text = oldName;
        usernameController.text = oldUsername;
        isGoogle = userData[0]['is_google'];
      });
    } else {
      if (mounted) {
        showMessage(context, translate("Error loading user info"));
      }
    }
  }

  String? passwordConfirmValidator(String? value) {
    bool isAnyFieldFilled = newPasswordController.text.isNotEmpty ||
        passwordConfirmController.text.isNotEmpty ||
        currentPasswordController.text.isNotEmpty;

    if (isAnyFieldFilled) {
      if (newPasswordController.text.isEmpty ||
          passwordConfirmController.text.isEmpty ||
          currentPasswordController.text.isEmpty) {
        return translate('All password fields must be filled');
      } else if (newPasswordController.text != passwordConfirmController.text) {
        return translate('Passwords do not match');
      }
    }

    return null;
  }

  void updateAccount() async {
    if (updateProfileForm.currentState!.validate()) {
      final response = await httpUpdateAccount(
        firstName:
            nameController.text.isNotEmpty && nameController.text != oldName
                ? nameController.text
                : null,
        username: usernameController.text.isNotEmpty &&
                usernameController.text != oldUsername
            ? usernameController.text
            : null,
        currentPassword: currentPasswordController.text.isNotEmpty &&
                newPasswordController.text.isNotEmpty
            ? currentPasswordController.text
            : null,
        newPassword: currentPasswordController.text.isNotEmpty &&
                newPasswordController.text.isNotEmpty
            ? newPasswordController.text
            : null,
        pickedImage: _pickedImage,
        defaultImage: defaultImage,
      );

      if (response.statusCode == 200) {
        if (mounted) {
          showMessage(context, translate('Profile updated'));
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          Map json = jsonDecode(response.body);
          if (json.containsKey("username")) {
            showMessage(context, translate(json["username"][0]));
          } else if (json.containsKey("error")) {
            showMessage(context, translate(json["error"]));
          } else {
            showMessage(context, translate('Error updating profile'));
          }
        }
      }
    }
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
