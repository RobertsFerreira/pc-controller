import 'package:flutter/material.dart';
import 'package:pc_remote_control/core/theme/theme_context.dart';

class AudioPage extends StatelessWidget {
  final String title;
  final String description;

  const AudioPage({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final layout = context.appLayoutTokens;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(layout.radiusXl),
      ),
      padding: EdgeInsets.all(layout.spacing2xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.headlineSmall,
          ),
          SizedBox(height: layout.spacingMd),
          Text(
            description,
            style: context.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: layout.spacingXl),
          Expanded(
            child: Center(
              child: Text(
                title,
                key: const Key('audio-module-page'),
                style: context.textTheme.titleLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
