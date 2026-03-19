import 'package:flutter/material.dart';
import 'package:pc_remote_control/core/components/menu_side/expansible_menu_side.dart';
import 'package:pc_remote_control/core/components/menu_side/menu_side_tile.dart';
import 'package:pc_remote_control/core/di/service_locator.dart';
import 'package:pc_remote_control/core/navigation/navigation_controller.dart';

class SideMenu extends StatelessWidget {
  static const double _menuSideWidth = 240;
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final navigation = serviceLocator<NavigationController>();

    return AnimatedBuilder(
      animation: navigation,
      builder: (context, _) {
        final scheme = Theme.of(context).colorScheme;

        final accent = scheme.primary;
        final textMuted = scheme.onSurfaceVariant;

        return SizedBox(
          width: _menuSideWidth,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF171B20),
                  Color(0xFF111418),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 20,
                  offset: Offset(6, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.dashboard_outlined,
                          color: accent,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Categorias',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textMuted,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: navigation.menuEntries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
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
