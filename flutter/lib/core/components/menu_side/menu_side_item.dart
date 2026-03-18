import 'package:flutter/material.dart';
import 'package:pc_remote_control/core/navigation/app_module.dart';

class MenuEntry {
  final String id;
  final String title;
  final IconData icon;
  final bool isSelected;
  final bool isExpanded;
  final List<MenuEntry> children;

  const MenuEntry({
    required this.id,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.isExpanded,
    this.children = const [],
  });

  bool get hasChildren => children.isNotEmpty;

  static MenuEntry fromModule(
    AppModuleNode module, {
    required String? selectedId,
    required Set<String> expandedIds,
  }) {
    final childEntries = module.children
        .map((child) {
          return MenuEntry.fromModule(
            child,
            selectedId: selectedId,
            expandedIds: expandedIds,
          );
        })
        .toList(growable: false);

    final hasSelectedDescendant = childEntries.any((entry) => entry.isSelected);

    return MenuEntry(
      id: module.id,
      title: module.title,
      icon: module.icon,
      isSelected: selectedId == module.id || hasSelectedDescendant,
      isExpanded: expandedIds.contains(module.id),
      children: childEntries,
    );
  }
}
