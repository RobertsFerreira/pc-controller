import 'package:flutter/material.dart';
import 'package:pc_remote_control/core/components/menu_side/menu_side_item.dart';
import 'package:pc_remote_control/core/components/menu_side/menu_side_tile.dart';

class ExpandableMenuTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final bool isExpanded;
  final Color accent;
  final Color muted;
  final VoidCallback onTap;
  final ValueChanged<String> onChildTap;
  final List<MenuEntry> children;

  const ExpandableMenuTile({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.isExpanded,
    required this.accent,
    required this.muted,
    required this.onTap,
    required this.onChildTap,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: scheme.surface.withValues(alpha: 0.6),
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
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isSelected ? accent : muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ClipRect(
          child: AnimatedAlign(
            alignment: Alignment.topCenter,
            duration: const Duration(milliseconds: 180),
            heightFactor: isExpanded ? 1 : 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 12, 12),
              child: Column(
                children: children
                    .map((child) {
                      return MenuTile(
                        title: child.title,
                        icon: child.icon,
                        accent: accent,
                        muted: muted,
                        isSelected: child.isSelected,
                        onTap: () => onChildTap(child.id),
                      );
                    })
                    .toList(growable: false),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
