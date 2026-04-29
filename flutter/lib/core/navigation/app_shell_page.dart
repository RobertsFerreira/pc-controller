import 'package:flutter/material.dart';
import 'package:pc_remote_control/core/di/service_locator.dart';
import 'package:pc_remote_control/core/navigation/menu_side.dart';
import 'package:pc_remote_control/core/navigation/navigation_controller.dart';
import 'package:pc_remote_control/core/theme/theme_context.dart';

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
        final appTheme = context.appLayoutTokens;

        return Scaffold(
          appBar: AppBar(
            title: Padding(
              padding: EdgeInsets.only(left: appTheme.spacingLg),
              child: Text('Control Hub'),
            ),
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
                        padding: EdgeInsets.all(
                          context.appLayoutTokens.spacingXl,
                        ),
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
