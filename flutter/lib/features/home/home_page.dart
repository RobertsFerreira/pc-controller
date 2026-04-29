import 'package:flutter/material.dart';
import 'package:pc_remote_control/core/theme/theme_context.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
            'Painel Inicial',
            style: context.textTheme.headlineSmall,
          ),
          SizedBox(height: layout.spacingMd),
          Text(
            'Escolha um modulo no menu lateral para navegar entre as areas do app.',
            style: context.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: layout.spacingXl),
          Expanded(
            child: Center(
              child: Text(
                'Home Module',
                style: context.textTheme.titleLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
