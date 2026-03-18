import 'package:flutter/material.dart';
import 'package:pc_remote_control/core/components/menu_side/expansible_menu_side.dart';
import 'package:pc_remote_control/core/components/menu_side/menu_side_tile.dart';
import 'package:pc_remote_control/core/navigation/app_module.dart';

class SideMenu extends StatelessWidget {
  final AppModule currentModule;
  static const double _menuSideWidth = 240;
  const SideMenu({super.key, required this.currentModule});

  @override
  Widget build(BuildContext context) {
    final modules = AppModule.getMenuModules();
    final scheme = Theme.of(context).colorScheme;
    final menuEntries = [];
    // final menuEntries = modules
    //     .map(
    //       (module) => MenuEntry(
    //         module: module,
    //         subEntries: module == AppModule.audio
    //             ? const [
    //                 SubMenuEntry(
    //                   id: 'devices',
    //                   title: 'Dispositivos',
    //                   icon: Icons.speaker_outlined,
    //                   isActive: true,
    //                 ),
    //                 SubMenuEntry(
    //                   id: 'sessions',
    //                   title: 'Sessoes',
    //                   icon: Icons.graphic_eq_outlined,
    //                   isActive: false,
    //                 ),
    //               ]
    //             : const [],
    //       ),
    //     )
    //     .toList();

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
                      color: accent.withOpacity(0.18),
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
                itemCount: menuEntries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final entry = menuEntries[index];
                  final isSelected = entry.module == currentModule;

                  if (entry.hasSubEntry) {
                    return MenuTile(
                      title: entry.module.title,
                      icon: entry.module.icon,
                      isSelected: isSelected,
                      accent: accent,
                      muted: textMuted,
                    );
                  }

                  return Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                    child: ExpandableMenuTile(
                      title: entry.module.title,
                      icon: entry.module.icon,
                      isSelected: isSelected,
                      accent: accent,
                      muted: textMuted,
                      initiallyExpanded: isSelected,
                      children: entry.subEntries,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
