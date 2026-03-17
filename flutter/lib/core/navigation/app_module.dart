import 'package:flutter/material.dart';
import 'package:pc_remote_control/features/audio/audio_page.dart';
import 'package:pc_remote_control/features/home/home_page.dart';

enum AppModule {
  home(
    title: 'Home',
    icon: Icons.home_outlined,
    order: 0,
    enabled: true,
  ),
  audio(
    title: 'Audio',
    icon: Icons.volume_up_outlined,
    order: 1,
    enabled: true,
  );

  final String title;
  final IconData icon;
  final int order;
  final bool enabled;

  const AppModule({
    required this.title,
    required this.icon,
    required this.order,
    required this.enabled,
  });

  static List<AppModule> getMenuModules() {
    final modules = AppModule.values.where((module) => module.enabled).toList();
    modules.sort((left, right) => left.order.compareTo(right.order));
    return modules;
  }

  Widget get page {
    return switch (this) {
      home => HomePage(),
      audio => AudioPage(),
    };
  }
}
