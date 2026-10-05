import 'package:flutter/material.dart';
import 'package:rahbar/core/theme/app_theme.dart';

class LanguageTogglePill extends StatelessWidget {
  final bool isUrdu;
  final ValueChanged<bool> onChanged;

  const LanguageTogglePill({
    Key? key,
    required this.isUrdu,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggle(
            text: 'English',
            icon: Icons.language,
            isSelected: !isUrdu,
            onTap: () => onChanged(false),
          ),
          _buildToggle(
            text: 'اردو',
            isSelected: isUrdu,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle({
    required String text,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.pakistanGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
