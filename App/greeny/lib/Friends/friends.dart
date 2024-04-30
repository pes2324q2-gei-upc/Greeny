import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/Friends/friend_profile.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<String> friends = ['Marc', 'Arnau', 'Friend 3', 'Friend 4'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        padding: EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Dos tarjetas por fila
          crossAxisSpacing: 10, // Espacio horizontal entre las tarjetas
          mainAxisSpacing: 10, // Espacio vertical entre las tarjetas
        ),
        itemCount: friends.length,
        itemBuilder: (BuildContext context, int index) {
          return buildFriendCard(
              friends[index]); // Construye la tarjeta del amigo
        },
      ),
    );
  }

  Widget buildFriendCard(String friendUsername) {
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
          borderRadius: BorderRadius.circular(15), // Bordes redondeados
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
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
                    'assets/images/perfil.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                friendUsername, // Nombre del amigo
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addFriend() {
    // Add friend code here
  }
}
