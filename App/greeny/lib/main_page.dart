import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'Map/map.dart';
import 'City/city.dart';
import 'Friends/friends.dart';
import 'Profile/profile_stats.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  int currentPageIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: <Widget>[
        const CityPage(),
        const MapPage(),
        const FriendsPage(),
        const ProfileStatsPage(),
      ][currentPageIndex],
      
      bottomNavigationBar: NavigationBar(
      onDestinationSelected: indexSelected,
      indicatorColor: Theme.of(context).colorScheme.inversePrimary,
      selectedIndex: currentPageIndex,
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      destinations: <Widget>[
        NavigationDestination(
          selectedIcon: const Icon(Icons.location_city),
          icon: const Icon(Icons.location_city_outlined),
          label: translate('City'),
        ),
        NavigationDestination(
          selectedIcon: const Icon(Icons.map),
          icon: const Icon(Icons.map_outlined),
          label: translate('Map'),
        ),
        NavigationDestination(
          selectedIcon: const Icon(Icons.people),
          icon: const Icon(Icons.people_outlined),
          label: translate('Friends'),
        ),
        NavigationDestination(
          selectedIcon: const Icon(Icons.person),
          icon: const Icon(Icons.person_outline),
          label: translate('Profile'),
        ),
      ],
    ),
    );
  }

  void indexSelected(int index) {
    setState(() {
      currentPageIndex = index;
    });
  }
}
