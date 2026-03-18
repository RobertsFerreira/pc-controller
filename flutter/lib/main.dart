import 'package:flutter/material.dart';
import 'package:pc_remote_control/core/di/injection_container.dart';
import 'package:pc_remote_control/core/navigation/app_shell_page.dart';

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
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4B86C6),
          secondary: Color(0xFF5FA8A3),
          surface: Color(0xFF181B20),
          surfaceContainerHighest: Color(0xFF23272E),
          onPrimary: Color(0xFFF7F8FA),
          onSurface: Color(0xFFE6E7EB),
          onSurfaceVariant: Color(0xFFB5BDC7),
          outline: Color(0xFF2E343E),
        ),
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
      ),
      home: const AppShellPage(),
    );
  }
}
