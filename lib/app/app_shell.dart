import 'package:flutter/material.dart';

import 'package:rahbar/presentation/home/home_screen.dart';
import 'package:rahbar/presentation/tracking/tracking_screen.dart';
import 'package:rahbar/presentation/guardians/guardian_screen.dart';
import 'package:rahbar/presentation/settings/settings_screen.dart';
import 'package:rahbar/presentation/shared/components/floating_bottom_navigation.dart';

class AppShell extends StatefulWidget {
  const AppShell({Key? key}) : super(key: key);

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  // Only primary destinations are kept in the IndexedStack
  final List<Widget> _screens = const [
    HomeScreen(),
    TrackingScreen(),
    GuardianScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows background to extend behind the floating nav
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FloatingBottomNavigation(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

