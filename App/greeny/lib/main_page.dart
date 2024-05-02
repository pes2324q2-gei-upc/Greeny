import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:greeny/API/requests.dart';
import 'Map/map.dart';
import 'City/city.dart';
import 'Friends/friends.dart';
import 'Profile/profile.dart';
import 'Statistics/statistics.dart';
import 'package:greeny/utils/utils.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentPageIndex = 0;
  int friendRequestsCount = 0;

  Timer _timer = Timer.periodic(const Duration(seconds: 5), (timer) {});

  @override
  void initState() {
    getFriends();
    super.initState();
    _timer =
        Timer.periodic(const Duration(seconds: 5), (timer) => getFriends());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> getFriends() async {
    friendRequestsCount = 0;

    const String endpointRequests = '/api/friend-requests/';
    final responseRequests = await httpGet(endpointRequests);

    if (responseRequests.statusCode == 200) {
      final List<dynamic> friendRequestsData =
          jsonDecode(responseRequests.body);
      setState(() {
        friendRequestsCount = friendRequestsData.length;
      });
    } else {
      final bodyReq = jsonDecode(responseRequests.body);
      // ignore: use_build_context_synchronously
      showMessage(context, translate(bodyReq['message']));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: <Widget>[
        const CityPage(),
        const MapPage(),
        const FriendsPage(),
        const StatisticsPage(),
        const ProfilePage(),
      ][currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: indexSelected,
        indicatorColor: Theme.of(context).colorScheme.inversePrimary,
        selectedIndex: currentPageIndex,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: const Icon(Icons.location_city_rounded),
            icon: const Icon(Icons.location_city_rounded),
            label: translate('City'),
          ),
          NavigationDestination(
            selectedIcon: const Icon(Icons.map_rounded),
            icon: const Icon(Icons.map_outlined),
            label: translate('Map'),
          ),
          NavigationDestination(
            selectedIcon: Stack(
              children: [
                const Icon(Icons.people_rounded),
                if (friendRequestsCount > 0)
                  Positioned(
                    left: 10,
                    bottom: 5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: Text(
                        friendRequestsCount.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            icon: Stack(
              children: [
                const Icon(Icons.people_outline_rounded),
                if (friendRequestsCount > 0)
                  Positioned(
                    left: 10,
                    bottom: 5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: Text(
                        friendRequestsCount.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: translate('Friends'),
          ),
          NavigationDestination(
            selectedIcon: const Icon(Icons.table_chart),
            icon: const Icon(Icons.table_chart_outlined),
            label: translate('Statistics'),
          ),
          NavigationDestination(
            selectedIcon: const Icon(Icons.person_rounded),
            icon: const Icon(Icons.person_outline_rounded),
            label: translate('Profile'),
          ),
        ],
      ),
    );
  }

  void indexSelected(int index) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    setState(() {
      currentPageIndex = index;
    });
  }
}
