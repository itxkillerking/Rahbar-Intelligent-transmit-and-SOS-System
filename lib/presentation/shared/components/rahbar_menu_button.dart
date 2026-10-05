import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:rahbar/core/theme/app_theme.dart';

class RahbarMenuButton extends StatefulWidget {
  final VoidCallback onPressed;

  const RahbarMenuButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  State<RahbarMenuButton> createState() => _RahbarMenuButtonState();
}

class _RahbarMenuButtonState extends State<RahbarMenuButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2), // Soft glass surface
            borderRadius: BorderRadius.circular(14), // Rounded shape
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), // Glassmorphism
              child: const Center(
                child: Icon(
                  Icons.menu_rounded,
                  color: Colors.white, // White icon for contrast on green header
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
