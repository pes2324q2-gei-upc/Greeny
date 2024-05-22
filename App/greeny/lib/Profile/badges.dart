import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:carousel_slider/carousel_slider.dart';

class BadgesPage extends StatefulWidget {
  final int level;
  final int maxLevel;
  final List<Widget> badges;

  const BadgesPage(
      {Key? key,
      required this.level,
      required this.badges,
      required this.maxLevel})
      : super(key: key);

  @override
  State<BadgesPage> createState() => _BadgesPageState();
}

class _BadgesPageState extends State<BadgesPage> {
  late int level;
  late List<Widget> badges;
  late int maxlevel;

  @override
  void initState() {
    super.initState();
    level = widget.level;
    badges = widget.badges;
    maxlevel = widget.maxLevel;
  }

  void updateLevel(int index) {
    setState(() {
      level = index;
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
                return Image.asset(
                  'assets/badges/${itemIndex}0.png',
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
              "Nivell ${(level + 1).toString()}",
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
