import 'package:flutter/material.dart';
import 'package:pc_remote_control/core/navigation/app_module.dart';
import 'package:pc_remote_control/core/navigation/menu_side.dart';

class HomePage extends StatelessWidget {
  final currentModule = AppModule.home;
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Column(
        children: [
          Divider(),
          Expanded(
            child: Row(
              children: [
                SideMenu(currentModule: currentModule),
                VerticalDivider(),
                Expanded(
                  child: SizedBox(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
