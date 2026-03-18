import 'package:flutter/material.dart';
import 'package:pc_remote_control/core/di/di_container.dart';

typedef ModulePageBuilder = Widget Function(BuildContext context);

class AppModuleNode {
  final String id;
  final String title;
  final IconData icon;
  final int order;
  final bool enabled;
  final ModulePageBuilder? pageBuilder;
  final List<AppModuleNode> children;

  const AppModuleNode({
    required this.id,
    required this.title,
    required this.icon,
    required this.order,
    this.enabled = true,
    this.pageBuilder,
    this.children = const [],
  });

  bool get hasChildren => children.isNotEmpty;
  bool get canOpenPage => pageBuilder != null;
}

abstract interface class FeatureModule {
  void register(DIContainer di);
  AppModuleNode get navigation;
}
