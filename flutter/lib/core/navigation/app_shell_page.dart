import 'package:flutter/material.dart';
import 'package:pc_remote_control/core/di/service_locator.dart';
import 'package:pc_remote_control/core/navigation/menu_side.dart';
import 'package:pc_remote_control/core/navigation/navigation_controller.dart';

class AppShellPage extends StatelessWidget {
  const AppShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final navigation = serviceLocator<NavigationController>();

    return AnimatedBuilder(
      animation: navigation,
      builder: (context, _) {
        final currentModule = navigation.selectedModule;
        final currentPage = currentModule?.pageBuilder?.call(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(currentModule?.title ?? 'Control Hub'),
          ),
          body: Column(
            children: [
              const Divider(),
              Expanded(
                child: Row(
                  children: [
                    const SideMenu(),
                    const VerticalDivider(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: currentPage ?? const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
