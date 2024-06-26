import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/requests.dart';
import 'package:greeny/Friends/friend_profile.dart';
import 'package:greeny/utils/utils.dart';

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
      if (mounted) {
        showMessage(context, translate("Error loading user info"));
      }
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
      final List<dynamic> friendsData =
          jsonDecode(utf8.decode(response.bodyBytes));
      friends = friendsData
          .map((friend) => {
                'username': friend['username'],
                'image': friend['image'],
              })
          .toList();
    } else {
      final body = jsonDecode(response.body);
      if (mounted) {
        showMessage(context, translate(body['message']));
      }
    }

    //Obtener solicitudes de amistad
    const String endpointRequests = '/api/friend-requests/';
    final responseRequests = await httpGet(endpointRequests);

    if (responseRequests.statusCode == 200) {
      final List<dynamic> friendRequestsData =
          jsonDecode(utf8.decode(responseRequests.bodyBytes));
      friendRequests = friendRequestsData.map((request) {
        final int solId = request['id'];
        final String fromUserName = request['from_user_username'];
        return {'id': solId, 'username': fromUserName};
      }).toList();
      friendRequestsUsers = friendRequestsData
          .map((request) => {
                'username': request['from_user_username'],
                'image': request['from_user_image'],
              })
          .toList();
    } else {
      final bodyReq = jsonDecode(responseRequests.body);
      if (mounted) {
        showMessage(context, translate(bodyReq['message']));
      }
    }

    // Combinar amigos y solicitudes de amistad
    setState(() {
      friendsTotal.addAll(friends);
      friendsTotal.addAll(friendRequestsUsers);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userUsername == '') {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 220, 255, 255),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
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
                    final String friendUsername =
                        friendsTotal[index]['username'];
                    final String image = friendsTotal[index]['image'];
                    final bool hasSentRequest = friendRequestsUsers.any(
                        (request) => request['username'] == friendUsername);
                    return buildFriendCard(
                        friendUsername, hasSentRequest, image);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void searchFriend(String username) async {
    if (username.isEmpty) {
      showMessage(context, translate('Please enter a username'));
      return;
    }
    if (username == userUsername) {
      showMessage(context, translate('You cannot add yourself as a friend'));
      return;
    }
    if (userUsername == '') {
      showMessage(context, translate('Error, please try again'));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => FriendProfilePage(friendUsername: username)),
    );
  }

  Widget buildFriendCard(String friendUsername, hasSentRequest, String image) {
    return GestureDetector(
      onTap: () {
        // Navegar al perfil del amigo
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  FriendProfilePage(friendUsername: friendUsername),
            )).then((_) {
          getFriends();
        });
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), // Color de la sombra
                      spreadRadius: 3, // Extensión de la sombra
                      blurRadius: 3, // Desenfoque de la sombra
                      offset: const Offset(0, 2), // Desplazamiento de la sombra
                    ),
                  ],
                ),
                child: CircleAvatar(backgroundImage: NetworkImage(image)),
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
      if (mounted) {
        showMessage(context, translate('Friend Request Accepted'));
      }
      // Recargar la pantalla
      setState(() {
        getFriends();
      });
    } else {
      if (mounted) {
        showMessage(context, translate('Error, please try again'));
      }
    }
  }

  void rejectFriendRequest(String friendUsername) async {
    int id = findIdByUsername(friendUsername);
    final response = await sendRejectFriendRequest(id);
    if (response.statusCode == 200) {
      // Recargar la pantalla
      if (mounted) {
        showMessage(context, translate('Friend Request Rejected'));
      }
      setState(() {
        getFriends();
      });
    } else {
      if (mounted) {
        showMessage(context, translate('Error, please try again'));
      }
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
