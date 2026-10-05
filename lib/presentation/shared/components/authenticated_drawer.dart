import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahbar/application/auth/auth_controller.dart';
import 'package:rahbar/presentation/profile/profile_screen.dart';
import 'package:rahbar/presentation/shared/components/rahbar_drawer.dart';
import 'package:rahbar/app/app_shell.dart';

class AuthenticatedDrawer extends ConsumerWidget {
  const AuthenticatedDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final profile = authState.profile;

    return RahbarDrawer(
      fullName: profile?.fullName ?? 'My Profile',
      identifier: profile?.username ?? profile?.phoneNumber ?? '',
      completionPercentage: profile?.completionPercentage ?? 0,
      isLoading: authState.isProfileLoading,
      hasError: authState.profileError != null,
      onProfileTap: () {
        if (kDebugMode) debugPrint('NAV: AppShell/Drawer → Profile');
        Navigator.pop(context); // close drawer
        // Prevent pushing duplicate profile screens if already on it
        if (ModalRoute.of(context)?.settings.name != '/profile') {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => const ProfileScreen(),
            settings: const RouteSettings(name: '/profile'),
          ));
        }
      },
      onLogoutTap: () {
        Navigator.pop(context); // close drawer
        ref.read(authControllerProvider.notifier).logout();
      },
    );
  }
}
