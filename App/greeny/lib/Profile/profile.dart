import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/requests.dart';
import 'package:greeny/API/user_auth.dart';
import 'package:greeny/Profile/edit_profile.dart';
import 'package:greeny/Profile/settings.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  static const Color smallCardColor = Color.fromARGB(255, 240, 235, 235);
  static const Color titolColor = Color.fromARGB(255, 133, 131, 131);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = '';
  String userEmail = '';
  String userUsername = '';

  @override
  void initState() {
    obtenirNomUsuari();
    getInfoUser();
    super.initState();
  }

  obtenirNomUsuari() async {
    userName = await UserAuth().readUserInfo('name');
    setState(() {
      userName = userName;
    });
  }

  Future<void> getInfoUser() async {
    Map<String, dynamic> statsData = {};

    final response = await httpGet('/api/user/');

    if (response.statusCode == 200) {
      setState(() {
        statsData = json.decode(response.body);
        userEmail = statsData['email'];
        userUsername = statsData['username'];
      });
    } else {
      showMessage("Error loading user info");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userName == '') {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 220, 255, 255),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 220, 255, 255),
        appBar: (AppBar(
          backgroundColor: const Color.fromARGB(255, 220, 255, 255),
          title: Text(translate('Profile'),
              style: const TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
            onPressed: share,
            icon: const Icon(Icons.ios_share),
            color: const Color.fromARGB(255, 1, 167, 164),
          ),
          actions: [
            IconButton(
              onPressed: showSettings,
              icon: const Icon(Icons.settings),
              color: const Color.fromARGB(255, 1, 167, 164),
            ),
          ],
        )),
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    const SizedBox(
                      height: 20, // Espacio entre la imagen y la tarjeta
                    ),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape
                            .circle, // Establece la forma como un círculo
                        border: Border.all(
                          color: const Color.fromARGB(
                              255, 1, 167, 164), // Color del borde
                          width: 5, // Ancho del borde
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey
                                .withOpacity(0.5), // Color de la sombra
                            spreadRadius: 3, // Extensión de la sombra
                            blurRadius: 3, // Desenfoque de la sombra
                            offset: Offset(0, 2), // Desplazamiento de la sombra
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            60), // Radio de borde igual a la mitad del ancho/alto
                        child: Image.asset(
                          'assets/images/perfil.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: const Color.fromARGB(255, 1, 167, 164)),
                        child: IconButton(
                          onPressed: showEdit,
                          icon: const Icon(
                            Icons.edit,
                            color: ProfilePage.smallCardColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  '@$userUsername',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: ProfilePage.titolColor,
                  ),
                ),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      width: double.infinity, // Ocupa todo el ancho disponible
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        color: Colors.white, // Color de fondo de la tarjeta
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey
                                .withOpacity(0.2), // Color de la sombra
                            spreadRadius: 5, // Extensión de la sombra
                            blurRadius: 7, // Desenfoque de la sombra
                            offset: Offset(0, 3), // Desplazamiento de la sombra
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20), // Espaciado interno
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          //aqui va la informació de l'usuari
                          const SizedBox(height: 10),
                          //Email
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: ProfilePage.smallCardColor),
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.email,
                                    color: ProfilePage.titolColor),
                                const SizedBox(width: 5),
                                const Text(
                                  'Email:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: ProfilePage.titolColor,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    userEmail, // Correu
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 5),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          //Data registre
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: ProfilePage.smallCardColor),
                            padding: const EdgeInsets.all(10),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.calendar_month,
                                    color: ProfilePage.titolColor),
                                SizedBox(width: 5),
                                Text(
                                  'Joined:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: ProfilePage.titolColor,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '24/03/24',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 5),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          //Nivell
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: ProfilePage.smallCardColor),
                            padding: const EdgeInsets.all(10),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.star, color: ProfilePage.titolColor),
                                SizedBox(width: 5),
                                Text(
                                  'Level:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: ProfilePage.titolColor,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '100',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 5),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          //Amics
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: ProfilePage.smallCardColor),
                            padding: const EdgeInsets.all(10),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people,
                                  color: ProfilePage.titolColor,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Friends:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: ProfilePage.titolColor,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '200',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 5),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          //Viatges
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: ProfilePage.smallCardColor),
                            padding: const EdgeInsets.all(10),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.route,
                                  color: ProfilePage.titolColor,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Trips:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: ProfilePage.titolColor,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '5',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 5),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          //Reviews
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: ProfilePage.smallCardColor),
                            padding: const EdgeInsets.all(10),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.reviews,
                                  color: ProfilePage.titolColor,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Reviews:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: ProfilePage.titolColor,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '10',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 5),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void showSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  void showEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    );
  }

  void showMessage(String m) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translate(m)),
          duration: const Duration(seconds: 10),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  void share() {}
}
