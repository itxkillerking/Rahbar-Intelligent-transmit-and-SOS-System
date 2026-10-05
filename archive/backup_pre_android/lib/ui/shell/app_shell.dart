import 'package:flutter/material.dart';

import '../screens/emergency_screen.dart';
import '../screens/guardian_screen.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';

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
    EmergencyScreen(),
    GuardianScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.warning_rounded), label: 'Emergency'),
          BottomNavigationBarItem(icon: Icon(Icons.shield_rounded), label: 'Guardians'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}
