import 'package:flutter/material.dart';
import 'package:pc_remote_control/core/theme/app_color_tokens.dart';
import 'package:pc_remote_control/core/theme/app_layout_tokens.dart';
import 'package:pc_remote_control/core/theme/side_menu_tokens.dart';

extension ThemeContextX on BuildContext {
  ThemeData get appTheme => Theme.of(this);
  ColorScheme get colorScheme => appTheme.colorScheme;
  TextTheme get textTheme => appTheme.textTheme;
  AppColorTokens get appColorTokens => appTheme.extension<AppColorTokens>()!;
  AppLayoutTokens get appLayoutTokens => appTheme.extension<AppLayoutTokens>()!;
  SideMenuTokens get sideMenuTokens => appTheme.extension<SideMenuTokens>()!;
}
