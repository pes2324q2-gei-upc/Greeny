import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PodiumAvatar extends StatelessWidget {
  final String profileImage;
  final int rank;
  final String username;
  final int points;

  const PodiumAvatar(
      {required this.profileImage,
      required this.rank,
      required this.username,
      required this.points,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 110,
      child: Stack(
        children: [
          // Imagen de perfil
          Positioned(
            top: 25,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(backgroundImage: NetworkImage(profileImage)),
            ),
          ),
          // Número de posición
          Positioned(
            left: 42.5,
            top: 120,
            child: CircleAvatar(
              backgroundColor: const Color.fromARGB(255, 1, 167, 164),
              radius: 12,
              child: Text(
                rank.toString(),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 150,
            width: 110,
            child: Text(
              username,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          Positioned(
            left: 0,
            top: 175,
            width: 110,
            child: Text(
              "${points.toString()} pts",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),
          ),
          if (rank == 1)
            Positioned(
              left: 0,
              top: 0,
              width: 110,
              child: Center(
                child: SvgPicture.asset(
                  'assets/svg/crown.svg',
                  height: 40,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
