import 'package:flutter/material.dart';
import 'map.dart';
import 'city.dart';
import 'friends.dart';
import 'profile_stats.dart';

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
      destinations: const <Widget>[
        NavigationDestination(
          selectedIcon: Icon(Icons.location_city),
          icon: Icon(Icons.location_city),
          label: 'City',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.map),
          icon: Icon(Icons.map_outlined),
          label: 'Map',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.people),
          icon: Icon(Icons.people_outlined),
          label: 'Friends',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.person),
          icon: Icon(Icons.person_outline),
          label: 'Profile',
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
