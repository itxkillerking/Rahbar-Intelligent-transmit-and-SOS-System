import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahbar/application/auth/auth_controller.dart';
import 'package:rahbar/app/app_shell.dart';
import 'package:rahbar/presentation/auth/login_screen.dart';
import 'package:rahbar/presentation/auth/otp_screen.dart';
import 'package:rahbar/presentation/profile/complete_profile_screen.dart';
import 'package:rahbar/core/theme/app_theme.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    switch (authState.status) {
      case AuthState.checkingSession:
        return const _SplashLoadingScreen();
      case AuthState.unauthenticated:
      case AuthState.requestingOtp:
      case AuthState.error:
        return const LoginScreen();
      case AuthState.otpRequested:
      case AuthState.verifyingOtp:
        return const OtpScreen();
      case AuthState.profileRequired:
        return const CompleteProfileScreen();
      case AuthState.authenticated:
        return const AppShell();
    }
  }
}

class _SplashLoadingScreen extends StatefulWidget {
  const _SplashLoadingScreen({Key? key}) : super(key: key);

  @override
  State<_SplashLoadingScreen> createState() => _SplashLoadingScreenState();
}

class _SplashLoadingScreenState extends State<_SplashLoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _animCtrl, curve: const Interval(0.3, 1.0, curve: Curves.easeOutQuart)));
    
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.greenGradient,
        ),
        child: Stack(
          children: [
            // Subtle watermark
            Positioned(
              right: -50,
              bottom: -20,
              child: Opacity(
                opacity: 0.05,
                child: Icon(Icons.shield_rounded, size: 300, color: Colors.white),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          height: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Column(
                        children: [
                          Text(
                            'The Rahbar',
                            style: AppTheme.displayStyle.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Intelligent Transit Security and SOS System',
                            textAlign: TextAlign.center,
                            style: AppTheme.bodyStyle.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                          ),
                          const SizedBox(height: 40),
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
