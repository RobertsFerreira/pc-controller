import 'package:flutter/material.dart';
import 'package:pc_remote_control/core/theme/theme_context.dart';

class MenuTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final Color accent;
  final Color muted;
  final VoidCallback onTap;

  const MenuTile({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.accent,
    required this.muted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final layout = context.appLayoutTokens;
    final sideMenu = context.sideMenuTokens;
    final colors = context.appColorTokens;
    final iconColor = isSelected ? accent : muted;
    final textColor = isSelected ? scheme.onSurface : muted;

    //TODO: rever uso do material aqui diretamente
    //TODO: rever sobre o inkWell para o resto dos botoes
    return Material(
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
                child: Icon(icon, color: iconColor, size: layout.tileIconSize),
              ),
              SizedBox(width: layout.tileGap),
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
                  width: layout.selectionIndicatorSize,
                  height: layout.selectionIndicatorSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
