import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/requests.dart';
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
  String _friendUsername = '';
  String userUsername = '';

  //Obtener username del usuario para evitar que se busque a sí mismo
  Future<void> getInfoUser() async {
    List<dynamic> userData = [];

    final response = await httpGet('/api/user/');

    if (response.statusCode == 200) {
      setState(() {
        userData = json.decode(response.body);
        userUsername = userData[0]['username'];
      });
    } else {
      showMessage("Error loading user info");
    }
  }

  @override
  void initState() {
    getFriends();
    getInfoUser();
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
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _friendUsername = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: translate('Search Profile'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 20.0),
                  hintStyle: const TextStyle(fontSize: 16.0),
                  suffixIcon: IconButton(
                    onPressed: () {
                      searchFriend(_friendUsername);
                    },
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount:
                    friendsTotal.length, // Usar la longitud de friendsTotal
                itemBuilder: (BuildContext context, int index) {
                  final String friendUsername = friendsTotal[index];
                  final bool hasSentRequest =
                      friendRequestsUsers.contains(friendUsername);
                  return buildFriendCard(friendUsername, hasSentRequest);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void searchFriend(String username) async {
    if (username.isEmpty) {
      showMessage(translate('Please enter a username'));
      return;
    }
    if (username == userUsername) {
      showMessage(translate('You cannot add yourself as a friend'));
      return;
    }
    if (userUsername == '') {
      showMessage(translate('Error, please try again'));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => FriendProfilePage(friendUsername: username)),
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
        color: const Color.fromARGB(255, 1, 167, 164),
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
                    color:
                        const Color.fromARGB(255, 0, 92, 90), // Color del borde
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

  Future<void> acceptFriendRequest(String friendUsername) async {
    int id = findIdByUsername(friendUsername);
    final response = await sendAcceptFriendRequest(id);
    if (response.statusCode == 200) {
      showMessage(translate('Friend Request Accepted'));
      // Recargar la pantalla
      setState(() {
        getFriends();
      });
    } else {
      showMessage(translate('Error, please try again'));
    }
  }

  void rejectFriendRequest(String friendUsername) async {
    int id = findIdByUsername(friendUsername);
    final response = await sendRejectFriendRequest(id);
    if (response.statusCode == 200) {
      // Recargar la pantalla
      showMessage(translate('Friend Request Rejected'));
      setState(() {
        getFriends();
      });
    } else {
      showMessage(translate('Error, please try again'));
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

  int findIdByUsername(String username) {
    for (var request in friendRequests) {
      if (request['username'] == username) {
        return request['id'];
      }
    }
    return 0; // Retorna 0 si no se encuentra el username
  }
}
