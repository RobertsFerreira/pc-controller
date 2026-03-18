import 'package:flutter/material.dart';
import 'package:pc_remote_control/core/navigation/app_module.dart';

class MenuEntry {
  final AppModule module;
  final List<SubMenuEntry> subEntries;

  const MenuEntry({
    required this.module,
    required this.subEntries,
  });

  bool get hasSubEntry => subEntries.isEmpty;
}

class SubMenuEntry {
  final String id;
  final String title;
  final IconData icon;
  final bool isActive;

  const SubMenuEntry({
    required this.id,
    required this.title,
    required this.icon,
    this.isActive = true,
  });
}
