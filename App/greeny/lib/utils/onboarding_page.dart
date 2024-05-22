import 'package:flutter/material.dart';
import 'package:greeny/main_page.dart';
import 'package:flutter_translate/flutter_translate.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 220, 255, 255),
      body: PageView(
        controller: _pageController,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: <Widget>[
          _createPage('assets/icons/appicon.png', translate('Welcome to Greeny!'), translate('Stop being greedy, be Greeny')),
          _createPage('assets/icons/appicon.png', translate('Purify districts'), translate('Walk or use public transportation to earn points and purify districts')),
          _createPage('assets/icons/appicon.png', translate('Earn badges'), translate('When you purify a district, you will earn a badge, collect them all')),
          _createPage('assets/icons/appicon.png', translate('Be the best'), translate('Compete with your friends and other users to climb positions in the ranking')),
          _createPage('assets/icons/appicon.png', translate('Statistics'), translate('View your statistics and check how you are doing')),
          _createPage('assets/icons/appicon.png', translate('Share'), translate('Share your achievements and statistics with your acquaintances')),
          // Añade más páginas si lo necesitas
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _currentPage != 5 // Si no estamos en la última página, mostramos el botón 'Saltar'
                    ? TextButton(
                        onPressed: () {
                          _pageController.animateToPage(5, duration: const Duration(milliseconds: 400), curve: Curves.linear);
                        },
                        child: const Text('Saltar', style: TextStyle(color:  Color.fromARGB(255, 1, 167, 164), fontWeight: FontWeight.w600, fontSize: 18)),
                      )
                    : const SizedBox.shrink(), // Si estamos en la última página, no mostramos nada
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (int i = 0; i < 6; i++) i == _currentPage ? _buildPageIndicator(true, i) : _buildPageIndicator(false, i)
                ],
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _currentPage != 5 // Si no estamos en la última página, mostramos la flecha
                    ? TextButton(
                        onPressed: () {
                          _pageController.animateToPage(_currentPage + 1, duration: const Duration(milliseconds: 400), curve: Curves.linear);
                        },
                        child: const Icon(Icons.arrow_forward, color:  Color.fromARGB(255, 1, 167, 164), size: 24.0),
                      )
                    : TextButton( // Si estamos en la última página, mostramos el botón 'Empezar'
                        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainPage())),
                        child: const Text('Empezar', style: TextStyle(color:  Color.fromARGB(255, 1, 167, 164), fontWeight: FontWeight.w600, fontSize: 18)),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createPage(String imagePath, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Image.asset(
              imagePath,
              fit: BoxFit.cover,
          ),
          const SizedBox(height: 40),
          Text(
            description,
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isCurrentPage, int pageIndex) {
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          pageIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.ease,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2.0),
        height: isCurrentPage ? 10.0 : 6.0,
        width: isCurrentPage ? 10.0 : 6.0,
        decoration: BoxDecoration(
          color: isCurrentPage ? const Color.fromARGB(255, 1, 167, 164) : Colors.grey,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}