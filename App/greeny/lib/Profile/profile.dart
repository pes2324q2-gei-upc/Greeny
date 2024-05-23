import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/requests.dart';
import 'package:greeny/API/user_auth.dart';
import 'package:greeny/Profile/badges.dart';
import 'package:greeny/Profile/edit_profile.dart';
import 'package:greeny/Profile/share.dart';
import 'package:intl/intl.dart';
import 'package:greeny/Registration/log_in.dart';
import 'package:greeny/utils/translate.dart' as t;
import 'package:greeny/utils/utils.dart';

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
  String dateJoined = '';
  String imagePath = '';
  int level = 0;
  int friends = 0;
  int trips = 0;
  int reviews = 0;
  int points = 0;
  int mastery = 1;

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
        userData = jsonDecode(utf8.decode(response.bodyBytes));
        userName = userData[0]['first_name'];
        userEmail = userData[0]['email'];
        userUsername = userData[0]['username'];
        dateJoined = DateFormat('dd-MM-yyyy')
            .format(DateTime.parse(userData[0]['date_joined']));
        level = userData[0]['level'];
        friends = userData[0]['friends_number'];
        trips = userData[0]['routes_number'];
        reviews = userData[0]['reviews_number'];
        imagePath = userData[0]['image'];
        mastery = userData[0]['mastery'];
        points = userData[0]['points'];
      });
    } else {
      if (mounted) {
        showMessage(context, translate("Error loading user info"));
      }
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
              icon: const Icon(Icons.language),
              color: const Color.fromARGB(255, 1, 167, 164),
              onPressed: () {
                t.showLanguageDialog(context);
              },
            )
          ],
        )),
        body: SingleChildScrollView(
          child: Center(
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey
                                  .withOpacity(0.5), // Color de la sombra
                              spreadRadius: 3, // Extensión de la sombra
                              blurRadius: 3, // Desenfoque de la sombra
                              offset: const Offset(
                                  0, 2), // Desplazamiento de la sombra
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                            backgroundImage: NetworkImage(imagePath)),
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
                    height: 20,
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
                    height: 5,
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_events_outlined,
                            color: ProfilePage.titolColor),
                        const SizedBox(width: 5),
                        Expanded(
                          child: buildBadges(level - 1, mastery),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
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
                          offset:
                              const Offset(0, 3), // Desplazamiento de la sombra
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: double.infinity,
                      minHeight: 0,
                    ),
                    child: SingleChildScrollView(
                      //padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        width:
                            double.infinity, // Ocupa todo el ancho disponible
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                          color: Colors.white, // Color de fondo de la tarjeta
                        ),
                        padding: const EdgeInsets.all(20), // Espaciado interno
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            //aqui va la informació de l'usuari
                            const SizedBox(height: 5),
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
                                      fontWeight: FontWeight.bold,
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.calendar_month,
                                      color: ProfilePage.titolColor),
                                  const SizedBox(width: 5),
                                  Text(
                                    translate('Joined:'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: ProfilePage.titolColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    dateJoined,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.star,
                                      color: ProfilePage.titolColor),
                                  const SizedBox(width: 5),
                                  Text(
                                    translate('Level:'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: ProfilePage.titolColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    level.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            //Mastery
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: ProfilePage.smallCardColor),
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.military_tech_rounded,
                                    color: ProfilePage.titolColor,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    translate('Mastery:'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: ProfilePage.titolColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    toRoman(mastery + 1),
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            //Points
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: ProfilePage.smallCardColor),
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.score_rounded,
                                    color: ProfilePage.titolColor,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    translate('Points:'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: ProfilePage.titolColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    points.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.people,
                                    color: ProfilePage.titolColor,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    translate('Friends:'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: ProfilePage.titolColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    friends.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.route,
                                    color: ProfilePage.titolColor,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    translate('Trips:'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: ProfilePage.titolColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    trips.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.reviews,
                                    color: ProfilePage.titolColor,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    translate('Reviews:'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: ProfilePage.titolColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    reviews.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: logOut, child: Text(translate('Log Out'))),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  String toRoman(int number) {
    // number must be 1, 2, 3 or 4.
    switch (number) {
      case 1:
        return 'I';
      case 2:
        return 'II';
      case 3:
        return 'III';
      case 4:
        return 'IV';
      default:
        return '';
    }
  }

  void logOut() async {
    await UserAuth().userLogout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LogInPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void showEdit() {
    Navigator.push(context,
            MaterialPageRoute(builder: (context) => const EditProfilePage()))
        .then((_) {
      getInfoUser();
    });
  }

  void share() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SharePage(
                level: level,
                mastery: mastery,
                name: userName,
                username: userUsername,
                imagePath: imagePath)));
  }

  void clickBadge(List<Widget> badges, int level, int maxLevel) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BadgesPage(
                badges: badges,
                level: level,
                maxLevel: maxLevel,
                mastery: mastery)));
  }

  Widget buildBadges(int level, int mastery) {
    List<Widget> badges = []; // Lista para almacenar las medallas

    if (mastery < 3) {
      //Si no tens el maxim nivell de maestria
      // Bucle para generar medallas basadas en el nivel
      for (int i = 0; i < level; i++) {
        int maxlevel;
        if (mastery == 0) {
          maxlevel = level - 1;
        } else {
          maxlevel = 9;
        }
        badges.add(
          Positioned(
            left: i * 25.0, // Espacio horizontal entre las medallas
            child: GestureDetector(
              onTap: () {
                clickBadge(badges, level, maxlevel);
              },
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
          ),
        );
      }
      if (mastery > 0) {
        int index = mastery - 1;
        for (int i = level; i < 10; i++) {
          badges.add(
            Positioned(
              left: i * 25.0, // Espacio horizontal entre las medallas
              child: GestureDetector(
                onTap: () {
                  clickBadge(badges, level, 9);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.asset(
                    'assets/badges/$i$index.png',
                    width: 40, // Ancho deseado
                    height: 40, // Alto deseado
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        }
      }
    } else {
      //Si tens el maxim nivell de maestria
      for (int i = 0; i < 10; i++) {
        badges.add(
          Positioned(
            left: i * 25.0, // Espacio horizontal entre las medallas
            child: GestureDetector(
              onTap: () {
                clickBadge(badges, level, 9);
              },
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
          ),
        );
      }
    }

    return SizedBox(
      height: 40,
      child: Stack(
        children: badges,
      ),
    );
  }
}
