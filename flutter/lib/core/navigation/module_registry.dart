import 'package:pc_remote_control/core/navigation/app_module.dart';

class ModuleRegistry {
  final List<AppModuleNode> _modules = [];

  void register(AppModuleNode module) => _modules.add(module);

  List<AppModuleNode> get menuModules => _sortNodes(_modules);

  String? get initialSelectedId => _findFirstNavigableNode(menuModules)?.id;

  AppModuleNode? findById(String id) => _findById(menuModules, id);

  List<String> ancestorIdsOf(String id) {
    final path = _findPath(menuModules, id);
    if (path == null || path.length <= 1) {
      return const [];
    }

    return path.take(path.length - 1).map((node) => node.id).toList();
  }

  AppModuleNode? _findFirstNavigableNode(List<AppModuleNode> nodes) {
    for (final node in nodes) {
      if (node.canOpenPage) {
        return node;
      }

      final child = _findFirstNavigableNode(node.children);
      if (child != null) {
        return child;
      }
    }

    return null;
  }

  AppModuleNode? _findById(List<AppModuleNode> nodes, String id) {
    for (final node in nodes) {
      if (node.id == id) {
        return node;
      }

      final child = _findById(node.children, id);
      if (child != null) {
        return child;
      }
    }

    return null;
  }

  List<AppModuleNode>? _findPath(List<AppModuleNode> nodes, String id) {
    for (final node in nodes) {
      if (node.id == id) {
        return [node];
      }

      final childPath = _findPath(node.children, id);
      if (childPath != null) {
        return [node, ...childPath];
      }
    }

    return null;
  }

  List<AppModuleNode> _sortNodes(List<AppModuleNode> nodes) {
    final sorted = nodes.where((node) => node.enabled).toList()
      ..sort((left, right) => left.order.compareTo(right.order));

    return sorted
        .map((node) {
          return AppModuleNode(
            id: node.id,
            title: node.title,
            icon: node.icon,
            order: node.order,
            enabled: node.enabled,
            pageBuilder: node.pageBuilder,
            children: _sortNodes(node.children),
          );
        })
        .toList(growable: false);
  }
}
