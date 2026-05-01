import 'package:flutter/material.dart';
import 'package:pc_remote_control/core/di/injection_container.dart';
import 'package:pc_remote_control/core/theme/app_theme.dart';
import 'package:pc_remote_control/l10n/generated/app_localizations.dart';
import 'package:pc_remote_control/l10n/l10n_context.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => context.l10n.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.darkTheme,
      home: Container(),
    );
  }
}
