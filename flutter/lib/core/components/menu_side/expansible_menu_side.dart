import 'package:flutter/material.dart';
import 'package:pc_remote_control/core/components/menu_side/menu_side_item.dart';
import 'package:pc_remote_control/core/components/menu_side/menu_side_tile.dart';
import 'package:pc_remote_control/core/theme/theme_context.dart';

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
    final scheme = context.colorScheme;
    final layout = context.appLayoutTokens;
    final sideMenu = context.sideMenuTokens;
    final colors = context.appColorTokens;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(layout.radiusLg),
            onTap: onTap,
            child: Padding(
              padding: sideMenu.tilePadding,
              child: Row(
                children: [
                  Container(
                    width: layout.tileIconContainerSize,
                    height: layout.tileIconContainerSize,
                    decoration: BoxDecoration(
                      color: colors.surfaceOverlay,
                      borderRadius: BorderRadius.circular(layout.radiusMd),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? accent : muted,
                      size: layout.tileIconSize,
                    ),
                  ),
                  SizedBox(width: layout.tileGap),
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
              padding: sideMenu.childPadding,
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
