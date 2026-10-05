import 'package:flutter/material.dart';
import 'package:rahbar/core/theme/app_theme.dart';

class RahbarPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final IconData? trailingIcon;

  const RahbarPrimaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.trailingIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: onPressed == null && !isLoading
              ? [Colors.grey.shade400, Colors.grey.shade500]
              : const [Color(0xFF0A7B44), Color(0xFF0F9856)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: onPressed == null && !isLoading
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF0A7B44).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : Row(
                    children: [
                      // To balance the layout if there is a trailing icon
                      if (trailingIcon != null)
                        const SizedBox(width: 48)
                      else
                        const Spacer(),
                        
                      Expanded(
                        flex: trailingIcon != null ? 1 : 0,
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      if (trailingIcon != null) ...[
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(trailingIcon, color: Colors.white, size: 20),
                        ),
                      ] else
                        const Spacer(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
