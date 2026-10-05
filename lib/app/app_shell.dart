import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahbar/application/navigation_controller.dart';

import 'package:rahbar/presentation/home/home_screen.dart';
import 'package:rahbar/presentation/tracking/tracking_screen.dart';
import 'package:rahbar/presentation/guardians/guardian_screen.dart';
import 'package:rahbar/presentation/settings/settings_screen.dart';
import 'package:rahbar/presentation/shared/components/floating_bottom_navigation.dart';
import 'package:rahbar/presentation/shared/components/authenticated_drawer.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({Key? key}) : super(key: key);

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
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
    final _currentIndex = ref.watch(appShellIndexProvider);
    
    return Scaffold(
      extendBody: true, // Allows background to extend behind the floating nav
      drawer: const AuthenticatedDrawer(),
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
                ref.read(appShellIndexProvider.notifier).state = index;
              },
            ),
          ),
        ],
      ),
    );
  }
}

