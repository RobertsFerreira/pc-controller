import 'dart:ui';

import 'package:flutter/material.dart';

@immutable
class AppLayoutTokens extends ThemeExtension<AppLayoutTokens> {
  final double spacingXs;
  final double spacingSm;
  final double spacingMd;
  final double spacingLg;
  final double spacingXl;
  final double spacing2xl;
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusXl;
  final double radiusPill;
  final double tileIconContainerSize;
  final double tileIconSize;
  final double subMenuIconSize;
  final double tileGap;
  final double selectionIndicatorSize;

  const AppLayoutTokens({
    required this.spacingXs,
    required this.spacingSm,
    required this.spacingMd,
    required this.spacingLg,
    required this.spacingXl,
    required this.spacing2xl,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusXl,
    required this.radiusPill,
    required this.tileIconContainerSize,
    required this.tileIconSize,
    required this.subMenuIconSize,
    required this.tileGap,
    required this.selectionIndicatorSize,
  });

  @override
  AppLayoutTokens copyWith({
    double? spacingXs,
    double? spacingSm,
    double? spacingMd,
    double? spacingLg,
    double? spacingXl,
    double? spacing2xl,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusXl,
    double? radiusPill,
    double? tileIconContainerSize,
    double? tileIconSize,
    double? subMenuIconSize,
    double? tileGap,
    double? selectionIndicatorSize,
    double? headerPadding,
  }) {
    return AppLayoutTokens(
      spacingXs: spacingXs ?? this.spacingXs,
      spacingSm: spacingSm ?? this.spacingSm,
      spacingMd: spacingMd ?? this.spacingMd,
      spacingLg: spacingLg ?? this.spacingLg,
      spacingXl: spacingXl ?? this.spacingXl,
      spacing2xl: spacing2xl ?? this.spacing2xl,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusXl: radiusXl ?? this.radiusXl,
      radiusPill: radiusPill ?? this.radiusPill,
      tileIconContainerSize:
          tileIconContainerSize ?? this.tileIconContainerSize,
      tileIconSize: tileIconSize ?? this.tileIconSize,
      subMenuIconSize: subMenuIconSize ?? this.subMenuIconSize,
      tileGap: tileGap ?? this.tileGap,
      selectionIndicatorSize:
          selectionIndicatorSize ?? this.selectionIndicatorSize,
    );
  }

  @override
  AppLayoutTokens lerp(ThemeExtension<AppLayoutTokens>? other, double t) {
    if (other is! AppLayoutTokens) {
      return this;
    }

    return AppLayoutTokens(
      spacingXs: lerpDouble(spacingXs, other.spacingXs, t)!,
      spacingSm: lerpDouble(spacingSm, other.spacingSm, t)!,
      spacingMd: lerpDouble(spacingMd, other.spacingMd, t)!,
      spacingLg: lerpDouble(spacingLg, other.spacingLg, t)!,
      spacingXl: lerpDouble(spacingXl, other.spacingXl, t)!,
      spacing2xl: lerpDouble(spacing2xl, other.spacing2xl, t)!,
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t)!,
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t)!,
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t)!,
      radiusXl: lerpDouble(radiusXl, other.radiusXl, t)!,
      radiusPill: lerpDouble(radiusPill, other.radiusPill, t)!,
      tileIconContainerSize: lerpDouble(
        tileIconContainerSize,
        other.tileIconContainerSize,
        t,
      )!,
      tileIconSize: lerpDouble(tileIconSize, other.tileIconSize, t)!,
      subMenuIconSize: lerpDouble(subMenuIconSize, other.subMenuIconSize, t)!,
      tileGap: lerpDouble(tileGap, other.tileGap, t)!,
      selectionIndicatorSize: lerpDouble(
        selectionIndicatorSize,
        other.selectionIndicatorSize,
        t,
      )!,
    );
  }
}
