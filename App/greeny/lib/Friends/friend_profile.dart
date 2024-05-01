import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/requests.dart';
import 'package:intl/intl.dart';

class FriendProfilePage extends StatefulWidget {
  final String friendUsername;

  const FriendProfilePage({super.key, required this.friendUsername});

  static const Color smallCardColor = Color.fromARGB(255, 240, 235, 235);
  static const Color titolColor = Color.fromARGB(255, 133, 131, 131);

  @override
  State<FriendProfilePage> createState() => _FriendProfilePageState();
}

class _FriendProfilePageState extends State<FriendProfilePage> {
  String friendName = '';
  String dateJoined = '';
  int level = 0;
  int friends = 0;
  int trips = 0;
  int reviews = 0;
  int friendId = 0;
  bool isFriend = false;

  @override
  void initState() {
    getInfoUser();
    super.initState();
    userIsFriend();
  }

  //Obtener información del usuario a visitar
  Future<void> getInfoUser() async {
    Map<String, dynamic> userData = {};

    final String endpoint = '/api/user/${widget.friendUsername}';
    if (mounted) {
      final response = await httpGet(endpoint);

      if (response.statusCode == 200) {
        setState(() {
          userData = json.decode(response.body);
          friendName = userData['first_name'];
          dateJoined = DateFormat('dd-MM-yyyy')
              .format(DateTime.parse(userData['date_joined']));
          level = userData['level'];
          friends = userData['friends_number'];
          trips = userData['routes_number'];
          reviews = userData['reviews_number'];
          friendId = userData['id'];
        });
      } else if (response.statusCode == 404) {
        showMessage(translate("User not found"));
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } else {
        showMessage(translate("Error loading user info"));
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      }
    }
  }

  //Comprobar si el usuario es amigo
  Future<void> userIsFriend() async {
    List<dynamic> userFriends = [];
    const String endpoint = '/api/friends/';
    final response = await httpGet(endpoint);

    if (response.statusCode == 200) {
      final List<dynamic> friendsData = jsonDecode(response.body);
      userFriends = friendsData.map((friend) => friend['username']).toList();
    } else {
      showMessage('Failed checking if user is friend');
    }
    isFriend = userFriends.contains(widget.friendUsername);
  }

  @override
  Widget build(BuildContext context) {
    if (friendName == '') {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 220, 255, 255),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 220, 255, 255),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            color: const Color.fromARGB(255, 1, 167, 164),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 220, 255, 255),
        appBar: (AppBar(
          backgroundColor: const Color.fromARGB(255, 220, 255, 255),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            color: const Color.fromARGB(255, 1, 167, 164),
          ),
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
                              offset: const Offset(
                                  0, 2), // Desplazamiento de la sombra
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              60), // Radio de borde igual a la mitad del ancho/alto
                          child: Image.asset(
                            'assets/images/blank-profile.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    '@${widget.friendUsername}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: FriendProfilePage.titolColor,
                    ),
                  ),
                  Text(
                    friendName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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
                            //Data registre
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: FriendProfilePage.smallCardColor),
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.calendar_month,
                                      color: FriendProfilePage.titolColor),
                                  const SizedBox(width: 5),
                                  Text(
                                    translate('Joined:'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: FriendProfilePage.titolColor,
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
                                  color: FriendProfilePage.smallCardColor),
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.star,
                                      color: FriendProfilePage.titolColor),
                                  const SizedBox(width: 5),
                                  Text(
                                    translate('Level:'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: FriendProfilePage.titolColor,
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
                            //Amics
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: FriendProfilePage.smallCardColor),
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.people,
                                    color: FriendProfilePage.titolColor,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    translate('Friends:'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: FriendProfilePage.titolColor,
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
                                  color: FriendProfilePage.smallCardColor),
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.route,
                                    color: FriendProfilePage.titolColor,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    translate('Trips:'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: FriendProfilePage.titolColor,
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
                                  color: FriendProfilePage.smallCardColor),
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.reviews,
                                    color: FriendProfilePage.titolColor,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    translate('Reviews:'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: FriendProfilePage.titolColor,
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
                  if (!isFriend) // Verifica si no es amigo
                    ElevatedButton(
                      onPressed: () {
                        sendFriendRequest(friendId);
                      },
                      child: Text(translate('Send Friend Request')),
                    )
                  else // Si es amigo
                    ElevatedButton(
                      onPressed: () {
                        deleteFriend();
                      },
                      child: Text(translate('Delete Friend')),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }
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

  void deleteFriend() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate('Confirm Delete')),
          content:
              Text(translate('Are you sure you want to delete this friend?')),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(translate('Cancel')),
            ),
            TextButton(
              onPressed: () async {
                if (mounted) {
                  final response = await httpDelete('/api/friends/$friendId/');

                  if (response.statusCode == 200) {
                    showMessage(translate('Friend deleted'));
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                  } else {
                    showMessage(translate('Error deleting friend'));
                  }
                }
              },
              child: Text(translate('Delete Friend')),
            ),
          ],
        );
      },
    );
  }

  void sendFriendRequest(int friendId) async {
    if (mounted) {
      final response = await httpPost('/api/friend-requests/',
          jsonEncode({'to_user': friendId}), 'application/json');

      if (response.statusCode == 200) {
        showMessage(translate('Friend request sent'));
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } else if (response.statusCode == 409) {
        showMessage(translate('Friend Request Already Sent'));
      } else {
        showMessage(translate('Error sending friend request'));
      }
    }
  }

  void share() {}
}
