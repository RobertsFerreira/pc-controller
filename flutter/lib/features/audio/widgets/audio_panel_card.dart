import 'package:flutter/material.dart';
import 'package:pc_remote_control/features/audio/theme/theme_context.dart';

class AudioPanelCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final Color? backgroundColor;
  final bool emphasize;

  const AudioPanelCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(24),
    this.gradient,
    this.backgroundColor,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: context.buildPanelDecoration(
        gradient: gradient,
        color: backgroundColor,
        emphasize: emphasize,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
