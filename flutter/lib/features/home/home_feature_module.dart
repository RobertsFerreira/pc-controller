import 'package:flutter/material.dart';
import 'package:pc_remote_control/core/di/di_container.dart';
import 'package:pc_remote_control/core/navigation/app_module.dart';
import 'package:pc_remote_control/features/home/home_page.dart';

class HomeFeatureModule implements FeatureModule {
  @override
  void register(DIContainer di) {}

  @override
  AppModuleNode get navigation => AppModuleNode(
    id: 'home',
    title: 'Home',
    icon: Icons.home_outlined,
    order: 0,
    pageBuilder: (_) => const HomePage(),
  );
}
