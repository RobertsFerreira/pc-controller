import 'package:flutter/material.dart';
import 'package:pc_remote_control/core/components/menu_side/expansible_menu_side.dart';
import 'package:pc_remote_control/core/components/menu_side/menu_side_tile.dart';
import 'package:pc_remote_control/core/di/service_locator.dart';
import 'package:pc_remote_control/core/navigation/navigation_controller.dart';
import 'package:pc_remote_control/core/theme/theme_context.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final navigation = serviceLocator<NavigationController>();

    return AnimatedBuilder(
      animation: navigation,
      builder: (context, _) {
        final scheme = context.colorScheme;
        final sideMenu = context.sideMenuTokens;

        final accent = scheme.primary;
        final textMuted = scheme.onSurfaceVariant;

        return SizedBox(
          width: sideMenu.width,
          child: Container(
            decoration: BoxDecoration(
              gradient: sideMenu.gradient,
              boxShadow: sideMenu.shadows,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: sideMenu.headerTopSpacing),
                Padding(
                  padding: sideMenu.headerPadding,
                  child: Text(
                    'Categorias',
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      color: textMuted,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                SizedBox(height: sideMenu.headerBottomSpacing),
                Expanded(
                  child: ListView.separated(
                    padding: sideMenu.listPadding,
                    itemCount: navigation.menuEntries.length,
                    separatorBuilder: (_, __) => SizedBox(
                      height: sideMenu.itemGap,
                    ),
                    itemBuilder: (context, index) {
                      final entry = navigation.menuEntries[index];

                      if (!entry.hasChildren) {
                        return MenuTile(
                          title: entry.title,
                          icon: entry.icon,
                          isSelected: entry.isSelected,
                          accent: accent,
                          muted: textMuted,
                          onTap: () => navigation.selectModule(entry.id),
                        );
                      }

                      return ExpandableMenuTile(
                        title: entry.title,
                        icon: entry.icon,
                        isSelected: entry.isSelected,
                        isExpanded: entry.isExpanded,
                        accent: accent,
                        muted: textMuted,
                        onTap: () => navigation.toggleExpanded(entry.id),
                        onChildTap: navigation.selectModule,
                        children: entry.children,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
