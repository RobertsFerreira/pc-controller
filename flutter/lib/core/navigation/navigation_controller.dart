import 'package:flutter/material.dart';
import 'package:pc_remote_control/core/navigation/app_module.dart';
import 'package:pc_remote_control/core/navigation/module_registry.dart';

//TODO: rever uso para bloc ou valuenotifier
class NavigationController extends ChangeNotifier {
  final ModuleRegistry _registry;
  final Set<String> _expandedIds = {};
  String? _selectedId;

  NavigationController({required ModuleRegistry registry})
    : _registry = registry,
      _selectedId = registry.initialSelectedId;

  List<AppModuleNode> get modules => _registry.menuModules;

  String? get selectedId => _selectedId;

  Set<String> get expandedIds => Set.unmodifiable(_expandedIds);

  AppModuleNode? get selectedModule {
    final currentId = _selectedId;
    if (currentId == null) return null;

    return _registry.findById(currentId);
  }

  void toggleExpanded(String id) {
    final node = _registry.findById(id);
    if (node == null || !node.hasChildren) return;

    if (_expandedIds.contains(id)) {
      _expandedIds.remove(id);
    } else {
      _expandedIds.add(id);
    }

    notifyListeners();
  }

  void selectModule(String id) {
    final node = _registry.findById(id);
    if (node == null || !node.canOpenPage) {
      return;
    }

    _selectedId = id;
    _expandedIds.addAll(_registry.ancestorIdsOf(id));
    notifyListeners();
  }
}
