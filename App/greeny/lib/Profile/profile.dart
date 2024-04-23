import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/user_auth.dart';
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

  @override
  void initState() {
    obtenirNomUsuari();
    super.initState();
  }

  obtenirNomUsuari() async {
    userName = await UserAuth().readUserInfo('name');
    setState(() {
      userName = userName;
    });
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
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.asset(
                            'assets/images/perfil.jpeg',
                            fit: BoxFit.cover,
                          )),
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
                        child: const Icon(
                          Icons.edit,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10, // Espacio entre la imagen y la tarjeta
                ),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 20, // Espacio entre la imagen y la tarjeta
                ),
                Expanded(
                  child: Container(
                    width: double.infinity, // Ocupa todo el ancho disponible
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      color: Colors.white, // Color de fondo de la tarjeta
                    ),
                    padding:
                        const EdgeInsets.all(20), // Espaciado interno opcional
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //aqui va la informació de l'usuari
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: ProfilePage.smallCardColor),
                          padding: const EdgeInsets.all(10),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.email,
                                  color: ProfilePage
                                      .titolColor), // Icono de correo electrónico
                              SizedBox(
                                  width:
                                      5), // Espacio entre el icono y el correo electrónico
                              Text(
                                'Email:', // Correo electrónico
                                style: TextStyle(
                                  fontSize: 16,
                                  color: ProfilePage.titolColor,
                                ),
                              ),
                              Spacer(),
                              Text(
                                'correo@ejemplo.com', // Correo electrónico
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 5),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: ProfilePage.smallCardColor),
                          padding: const EdgeInsets.all(10),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_month,
                                  color: ProfilePage
                                      .titolColor), // Icono de correo electrónico
                              SizedBox(
                                  width:
                                      5), // Espacio entre el icono y el correo electrónico
                              Text(
                                'Joined:', // Correo electrónico
                                style: TextStyle(
                                  fontSize: 16,
                                  color: ProfilePage.titolColor,
                                ),
                              ),
                              Spacer(),
                              Text(
                                '24/03/24', // Correo electrónico
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 5),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: ProfilePage.smallCardColor),
                          padding: const EdgeInsets.all(10),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.star,
                                  color: ProfilePage
                                      .titolColor), // Icono de correo electrónico
                              SizedBox(
                                  width:
                                      5), // Espacio entre el icono y el correo electrónico
                              Text(
                                'Level:', // Correo electrónico
                                style: TextStyle(
                                  fontSize: 16,
                                  color: ProfilePage.titolColor,
                                ),
                              ),
                              Spacer(),
                              Text(
                                '100', // Correo electrónico
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 5),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
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
                              ), // Icono de correo electrónico
                              SizedBox(
                                  width:
                                      5), // Espacio entre el icono y el correo electrónico
                              Text(
                                'Friends:', // Correo electrónico
                                style: TextStyle(
                                  fontSize: 16,
                                  color: ProfilePage.titolColor,
                                ),
                              ),
                              Spacer(),
                              Text(
                                '200', // Correo electrónico
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 5),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20, // Espacio entre la imagen y la tarjeta
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

  void share() {}
}
