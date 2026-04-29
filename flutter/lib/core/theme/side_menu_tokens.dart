import 'dart:ui';

import 'package:flutter/material.dart';

@immutable
class SideMenuTokens extends ThemeExtension<SideMenuTokens> {
  final double width;
  final double containerRadius;
  final double headerTopSpacing;
  final double headerBottomSpacing;
  final double itemGap;
  final EdgeInsets headerPadding;
  final EdgeInsets listPadding;
  final EdgeInsets tilePadding;
  final EdgeInsets childPadding;
  final LinearGradient gradient;
  final List<BoxShadow> shadows;

  const SideMenuTokens({
    required this.width,
    required this.containerRadius,
    required this.headerTopSpacing,
    required this.headerBottomSpacing,
    required this.itemGap,
    required this.headerPadding,
    required this.listPadding,
    required this.tilePadding,
    required this.childPadding,
    required this.gradient,
    required this.shadows,
  });

  @override
  SideMenuTokens copyWith({
    double? width,
    double? containerRadius,
    double? headerTopSpacing,
    double? headerBottomSpacing,
    double? itemGap,
    EdgeInsets? headerPadding,
    EdgeInsets? listPadding,
    EdgeInsets? tilePadding,
    EdgeInsets? childPadding,
    LinearGradient? gradient,
    List<BoxShadow>? shadows,
  }) {
    return SideMenuTokens(
      width: width ?? this.width,
      containerRadius: containerRadius ?? this.containerRadius,
      headerTopSpacing: headerTopSpacing ?? this.headerTopSpacing,
      headerBottomSpacing: headerBottomSpacing ?? this.headerBottomSpacing,
      itemGap: itemGap ?? this.itemGap,
      headerPadding: headerPadding ?? this.headerPadding,
      listPadding: listPadding ?? this.listPadding,
      tilePadding: tilePadding ?? this.tilePadding,
      childPadding: childPadding ?? this.childPadding,
      gradient: gradient ?? this.gradient,
      shadows: shadows ?? this.shadows,
    );
  }

  @override
  SideMenuTokens lerp(ThemeExtension<SideMenuTokens>? other, double t) {
    if (other is! SideMenuTokens) {
      return this;
    }

    return SideMenuTokens(
      width: lerpDouble(width, other.width, t)!,
      containerRadius: lerpDouble(containerRadius, other.containerRadius, t)!,
      headerTopSpacing: lerpDouble(
        headerTopSpacing,
        other.headerTopSpacing,
        t,
      )!,
      headerBottomSpacing: lerpDouble(
        headerBottomSpacing,
        other.headerBottomSpacing,
        t,
      )!,
      itemGap: lerpDouble(itemGap, other.itemGap, t)!,
      headerPadding: EdgeInsets.lerp(headerPadding, other.headerPadding, t)!,
      listPadding: EdgeInsets.lerp(listPadding, other.listPadding, t)!,
      tilePadding: EdgeInsets.lerp(tilePadding, other.tilePadding, t)!,
      childPadding: EdgeInsets.lerp(childPadding, other.childPadding, t)!,
      gradient: LinearGradient.lerp(gradient, other.gradient, t)!,
      shadows: BoxShadow.lerpList(shadows, other.shadows, t) ?? shadows,
    );
  }
}
