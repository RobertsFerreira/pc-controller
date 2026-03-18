import 'package:flutter/material.dart';
import 'package:pc_remote_control/core/components/menu_side/menu_side_item.dart';
import 'package:pc_remote_control/core/components/menu_side/menu_side_tile.dart';

class ExpandableMenuTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final Color accent;
  final Color muted;
  final bool initiallyExpanded;
  final List<SubMenuEntry> children;

  const ExpandableMenuTile({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.accent,
    required this.muted,
    required this.initiallyExpanded,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      childrenPadding: const EdgeInsets.fromLTRB(28, 0, 12, 12),
      initiallyExpanded: initiallyExpanded,
      iconColor: accent,
      collapsedIconColor: muted,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: scheme.surface.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isSelected ? accent : muted,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: isSelected ? scheme.onSurface : muted,
              ),
            ),
          ),
        ],
      ),
      children: [
        for (final child in children)
          SubMenuTile(
            title: child.title,
            icon: child.icon,
            accent: accent,
            muted: muted,
            isActive: child.isActive,
          ),
      ],
    );
  }
}
