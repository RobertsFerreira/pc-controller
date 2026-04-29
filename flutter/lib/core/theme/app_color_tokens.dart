import 'package:flutter/material.dart';

@immutable
class AppColorTokens extends ThemeExtension<AppColorTokens> {
  final Color menuGradientStart;
  final Color menuGradientEnd;
  final Color menuShadow;
  final Color surfaceOverlay;

  const AppColorTokens({
    required this.menuGradientStart,
    required this.menuGradientEnd,
    required this.menuShadow,
    required this.surfaceOverlay,
  });

  @override
  AppColorTokens copyWith({
    Color? menuGradientStart,
    Color? menuGradientEnd,
    Color? menuShadow,
    Color? surfaceOverlay,
  }) {
    return AppColorTokens(
      menuGradientStart: menuGradientStart ?? this.menuGradientStart,
      menuGradientEnd: menuGradientEnd ?? this.menuGradientEnd,
      menuShadow: menuShadow ?? this.menuShadow,
      surfaceOverlay: surfaceOverlay ?? this.surfaceOverlay,
    );
  }

  @override
  AppColorTokens lerp(ThemeExtension<AppColorTokens>? other, double t) {
    if (other is! AppColorTokens) {
      return this;
    }

    return AppColorTokens(
      menuGradientStart: Color.lerp(
        menuGradientStart,
        other.menuGradientStart,
        t,
      )!,
      menuGradientEnd: Color.lerp(menuGradientEnd, other.menuGradientEnd, t)!,
      menuShadow: Color.lerp(menuShadow, other.menuShadow, t)!,
      surfaceOverlay: Color.lerp(surfaceOverlay, other.surfaceOverlay, t)!,
    );
  }
}
