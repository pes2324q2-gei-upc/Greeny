import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/main.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  Animation<double>? animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Navigator.of(context).pushReplacementNamed('/nextPage');
        }
      });

    startAnimationNotifier.addListener(() {
      if (startAnimationNotifier.value) {
        _controller.forward();
      }
    });

    Future.delayed(const Duration(seconds: 3), () {
    if (mounted) {
      showMessage('Connection to the server is not working');
    }
  });

    animation = Tween<double>(begin: 1, end: 0).animate(_controller);
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 220, 255, 255),
    body: AnimatedOpacity(
      opacity: startAnimationNotifier.value ? 0.0 : 1.0,
      duration: _controller.duration!,
      child: Stack(
        alignment: Alignment.center,
        children: [
          FadeTransition(
            opacity: animation!,
            child: Center( // Add this line
              child: Container(
                padding: const EdgeInsets.all(120),
                child: const Image(image: AssetImage('assets/icons/appicon.png')),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  @override
  void dispose() {
    startAnimationNotifier.removeListener(() {});
    _controller.dispose();
    super.dispose();
  }

  void startAnimation() {
    _controller.forward();
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
}
