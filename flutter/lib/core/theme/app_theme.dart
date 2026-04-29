import 'package:flutter/material.dart';
import 'package:pc_remote_control/core/theme/app_color_tokens.dart';
import 'package:pc_remote_control/core/theme/app_layout_tokens.dart';
import 'package:pc_remote_control/core/theme/side_menu_tokens.dart';

class AppTheme {
  static final ColorScheme _darkColorScheme = const ColorScheme.dark(
    primary: Color(0xFF4B86C6),
    secondary: Color(0xFF5FA8A3),
    surface: Color(0xFF181B20),
    surfaceContainerHighest: Color(0xFF23272E),
    onPrimary: Color(0xFFF7F8FA),
    onSurface: Color(0xFFE6E7EB),
    onSurfaceVariant: Color(0xFFB5BDC7),
    outline: Color(0xFF2E343E),
  );

  static const AppColorTokens _colorTokens = AppColorTokens(
    menuGradientStart: Color(0xFF171B20),
    menuGradientEnd: Color(0xFF111418),
    menuShadow: Color(0x66000000),
    surfaceOverlay: Color(0x99181B20),
  );

  static const AppLayoutTokens _layoutTokens = AppLayoutTokens(
    spacingXs: 4,
    spacingSm: 8,
    spacingMd: 12,
    spacingLg: 16,
    spacingXl: 24,
    spacing2xl: 28,
    radiusSm: 8,
    radiusMd: 10,
    radiusLg: 16,
    radiusXl: 24,
    radiusPill: 999,
    tileIconContainerSize: 32,
    tileIconSize: 18,
    subMenuIconSize: 14,
    tileGap: 12,
    selectionIndicatorSize: 6,
  );

  static final SideMenuTokens _sideMenuTokens = SideMenuTokens(
    width: 240,
    containerRadius: 20,
    headerTopSpacing: _layoutTokens.spacingSm,
    headerBottomSpacing: _layoutTokens.spacingSm,
    headerPadding: EdgeInsets.symmetric(horizontal: 30),
    itemGap: 14,
    listPadding: EdgeInsets.fromLTRB(
      _layoutTokens.spacingLg,
      _layoutTokens.spacingSm,
      _layoutTokens.spacingLg,
      _layoutTokens.spacingLg,
    ),
    tilePadding: EdgeInsets.symmetric(
      horizontal: _layoutTokens.spacingMd,
      vertical: 10,
    ),
    childPadding: EdgeInsets.fromLTRB(
      _layoutTokens.spacing2xl,
      0,
      _layoutTokens.spacingMd,
      _layoutTokens.spacingMd,
    ),
    gradient: LinearGradient(
      colors: [
        _colorTokens.menuGradientStart,
        _colorTokens.menuGradientEnd,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    shadows: [
      BoxShadow(
        color: _colorTokens.menuShadow,
        blurRadius: 20,
        offset: const Offset(6, 10),
      ),
    ],
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _darkColorScheme,
      scaffoldBackgroundColor: const Color(0xFF0F1114),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF14171B),
        foregroundColor: Color(0xFFE6E7EB),
        elevation: 0,
        centerTitle: false,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2B313A),
        thickness: 1,
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: Color(0xFFB5BDC7),
        textColor: Color(0xFFE6E7EB),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE6E7EB),
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE6E7EB),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.45,
          color: Color(0xFFE6E7EB),
        ),
        bodyMedium: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE6E7EB),
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        _colorTokens,
        _layoutTokens,
        _sideMenuTokens,
      ],
    );
  }
}
