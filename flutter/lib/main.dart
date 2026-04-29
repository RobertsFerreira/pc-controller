import 'package:flutter/material.dart';
import 'package:pc_remote_control/core/di/injection_container.dart';
import 'package:pc_remote_control/core/navigation/app_shell_page.dart';
import 'package:pc_remote_control/core/theme/app_theme.dart';

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
      title: 'Control Hub',
      theme: AppTheme.darkTheme,
      home: const AppShellPage(),
    );
  }
}
