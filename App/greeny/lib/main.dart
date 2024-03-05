import 'package:flutter/material.dart';
import 'log_in.dart';

void main() {
  runApp(const Greeny());
}

class Greeny extends StatelessWidget {
  const Greeny({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LogInPage(),
    );
  }
}
