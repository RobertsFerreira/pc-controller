import 'package:flutter/material.dart';
import 'package:pc_remote_control/core/di/injection_container.dart';
import 'package:pc_remote_control/core/di/service_locator.dart';
import 'package:pc_remote_control/core/logging/app_logger.dart';
import 'package:pc_remote_control/core/logging/global_error_hooks.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();

  final logger = serviceLocator<AppLogger>();
  configureGlobalErrorHooks(logger);

  runAppWithErrorLogging(
    logger,
    () => runApp(const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PC Remote Control',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'PC Remote Control'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(child: Text('PC Remote Control')),
    );
  }
}
