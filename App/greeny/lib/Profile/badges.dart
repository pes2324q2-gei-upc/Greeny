import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:carousel_slider/carousel_slider.dart';

class BadgesPage extends StatefulWidget {
  final int level;
  final int maxLevel;
  final List<Widget> badges;
  final int mastery;

  const BadgesPage(
      {super.key,
      required this.level,
      required this.badges,
      required this.maxLevel,
      required this.mastery});

  @override
  State<BadgesPage> createState() => _BadgesPageState();
}

class _BadgesPageState extends State<BadgesPage> {
  late int level;
  late List<Widget> badges;
  late int maxlevel;
  late int mastery;
  int currentlevel = 0;

  @override
  void initState() {
    super.initState();
    level = widget.level;
    badges = widget.badges;
    maxlevel = widget.maxLevel;
    mastery = widget.mastery;
  }

  void updateLevel(int index) {
    setState(() {
      currentlevel = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 220, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 220, 255, 255),
        title: Text(
          translate('Badges'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            CarouselSlider.builder(
              itemCount: maxlevel + 1,
              itemBuilder:
                  (BuildContext context, int itemIndex, int pageViewIndex) {
                String imagePath;
                if (mastery <= 0) {
                  if (itemIndex < level) {
                    imagePath = 'assets/badges/${itemIndex}0.png';
                  } else {
                    return const SizedBox();
                  }
                } else if (itemIndex > level - 1 && mastery < 3) {
                  if (mastery > 0) {
                    imagePath = 'assets/badges/$itemIndex${mastery - 1}.png';
                  } else {
                    imagePath = 'assets/badges/${itemIndex}0.png';
                  }
                } else if (mastery >= 3) {
                  imagePath = 'assets/badges/${itemIndex}2.png';
                } else {
                  imagePath = 'assets/badges/$itemIndex$mastery.png';
                }

                return Image.asset(
                  imagePath,
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                );
              },
              options: CarouselOptions(
                height: 300,
                enlargeCenterPage: true,
                onPageChanged: (index, reason) {
                  updateLevel(index);
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "${translate('Level')} ${(currentlevel + 1).toString()}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
