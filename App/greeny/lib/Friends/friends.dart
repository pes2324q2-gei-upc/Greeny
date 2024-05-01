import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/requests.dart';
import 'package:greeny/Friends/add_friend.dart';
import 'package:greeny/Friends/friend_profile.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<dynamic> friends = [];
  List<dynamic> friendRequests = [];
  List<dynamic> friendRequestsUsers = [];
  List<dynamic> friendsTotal = [];

  @override
  void initState() {
    getFriends();
    super.initState();
  }

  Future<void> getFriends() async {
    friends = [];
    friendRequests = [];
    friendRequestsUsers = [];
    friendsTotal = [];

    //Obtener amigos
    const String endpoint = '/api/friends/';
    final response = await httpGet(endpoint);

    if (response.statusCode == 200) {
      final List<dynamic> friendsData = jsonDecode(response.body);
      friends = friendsData.map((friend) => friend['username']).toList();
    } else {
      final body = jsonDecode(response.body);
      showMessage(body['message']);
    }

    //Obtener solicitudes de amistad
    const String endpointRequests = '/api/friend-requests/';
    final responseRequests = await httpGet(endpointRequests);

    if (responseRequests.statusCode == 200) {
      final List<dynamic> friendRequestsData =
          jsonDecode(responseRequests.body);
      friendRequests = friendRequestsData.map((request) {
        final int solId = request['id'];
        final String fromUserName = request['from_user_username'];
        return {'id': solId, 'username': fromUserName};
      }).toList();
      friendRequestsUsers = friendRequestsData
          .map((request) => request['from_user_username'])
          .toList();
    } else {
      final bodyReq = jsonDecode(responseRequests.body);
      showMessage(bodyReq['message']);
    }

    // Combinar amigos y solicitudes de amistad
    setState(() {
      friendsTotal.addAll(friends);
      friendsTotal.addAll(friendRequestsUsers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: getFriends,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 220, 255, 255),
        appBar: AppBar(
          title: Text(translate('Friends'),
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          backgroundColor: const Color.fromARGB(255, 220, 255, 255),
          actions: [
            IconButton(
              onPressed: addFriend,
              icon: const Icon(Icons.person_add),
              color: const Color.fromARGB(255, 1, 167, 164),
            ),
          ],
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: friendsTotal.length, // Usar la longitud de friendsTotal
          itemBuilder: (BuildContext context, int index) {
            final String friendUsername = friendsTotal[index];
            final bool hasSentRequest =
                friendRequestsUsers.contains(friendUsername);
            return buildFriendCard(friendUsername, hasSentRequest);
          },
        ),
      ),
    );
  }

  Widget buildFriendCard(String friendUsername, hasSentRequest) {
    return GestureDetector(
      onTap: () {
        // Navegar al perfil del amigo
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                FriendProfilePage(friendUsername: friendUsername),
          ),
        );
      },
      child: Card(
        elevation: 3, // Elevación de la tarjeta
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25), // Bordes redondeados
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: hasSentRequest ? 60 : 90,
                height: hasSentRequest ? 60 : 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // Establece la forma como un círculo
                  border: Border.all(
                    color: const Color.fromARGB(
                        255, 1, 167, 164), // Color del borde
                    width: 5, // Ancho del borde
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), // Color de la sombra
                      spreadRadius: 3, // Extensión de la sombra
                      blurRadius: 3, // Desenfoque de la sombra
                      offset: const Offset(0, 2), // Desplazamiento de la sombra
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
              const SizedBox(height: 9),
              Text(
                friendUsername, // Nombre del amigo
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (hasSentRequest)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        acceptFriendRequest(friendUsername);
                      },
                      icon: const Icon(Icons.check),
                    ),
                    IconButton(
                      onPressed: () {
                        rejectFriendRequest(friendUsername);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void addFriend() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddFriendPage()),
    );
  }

  void acceptFriendRequest(String friendUsername) {
    int id = findIdByUsername(friendUsername);
    httpDelete('/api/friend-requests/$id/').then((response) {
      if (response.statusCode == 200) {
        // Recargar la pantalla
        setState(() {
          getFriends();
        });
      } else {
        showMessage(translate('Error, please try again'));
      }
    });
  }

  void rejectFriendRequest(String friendUsername) {
    print('Rechazar solicitud de amistad de $friendUsername');
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

  int findIdByUsername(String username) {
    for (var request in friendRequests) {
      if (request['username'] == username) {
        return request['id'];
      }
    }
    return 0; // Retorna 0 si no se encuentra el username
  }
}
