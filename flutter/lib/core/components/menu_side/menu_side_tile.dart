import 'package:flutter/material.dart';

class MenuTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final Color accent;
  final Color muted;

  const MenuTile({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.accent,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final iconColor = isSelected ? accent : muted;
    final textColor = isSelected ? scheme.onSurface : muted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          if (isSelected)
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent,
              ),
            ),
        ],
      ),
    );
  }
}

class SubMenuTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final Color muted;
  final bool isActive;

  const SubMenuTile({
    super.key,
    required this.title,
    required this.icon,
    required this.accent,
    required this.muted,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final activeBackground = accent.withValues(alpha: 0.18);
    final activeText = accent;
    final inactiveText = muted.withValues(alpha: 0.9);
    final iconColor = isActive ? accent : muted.withValues(alpha: 0.75);

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? activeBackground : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: isActive ? activeText : inactiveText,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
