import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class RankPage extends StatefulWidget {
  const RankPage({super.key});

  @override
  State<RankPage> createState() => _RankPageState();
}

class _RankPageState extends State<RankPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          Text(
            translate('Ranking'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ));
  }
}
