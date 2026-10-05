import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SosButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isActive;

  const SosButton({
    Key? key,
    required this.onPressed,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          color: isActive ? AppTheme.warningColor : AppTheme.primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isActive ? AppTheme.warningColor : AppTheme.primaryColor).withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: 10,
            )
          ],
        ),
        child: Center(
          child: Text(
            isActive ? 'ACTIVE' : 'SOS',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
