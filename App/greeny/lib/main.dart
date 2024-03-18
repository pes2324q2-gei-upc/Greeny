import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'Registration/log_in.dart';

void main() async {
  await dotenv.load(fileName: ".env");
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
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 1, 167, 164)),
        useMaterial3: true,
      ),
      home: const LogInPage(),
    );
  }
}
