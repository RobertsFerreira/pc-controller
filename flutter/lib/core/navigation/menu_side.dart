import 'package:flutter/material.dart';
import 'package:pc_remote_control/core/navigation/app_module.dart';

class SideMenu extends StatelessWidget {
  final AppModule currentModule;
  static const double _menuSideWidth = 240;
  const SideMenu({super.key, required this.currentModule});

  @override
  Widget build(BuildContext context) {
    final modules = AppModule.getMenuModules();

    return SizedBox(
      width: _menuSideWidth,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    'Categories',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView.separated(
                      itemCount: modules.length,
                      separatorBuilder: (_, index) => SizedBox(height: 20),
                      itemBuilder: (_, index) {
                        final module = modules[index];
                        return Container(
                          height: 40,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.blue[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Row(
                              children: [
                                Icon(module.icon),
                                const SizedBox(width: 20),
                                Text(module.title),
                              ],
                            ),
                          ),
                        );
                      },
                      // children: modules.map((module) {
                      //   final isSelected = module == currentModule;
                      //   return Container(
                      //     decoration: isSelected
                      //         ? BoxDecoration(
                      //             borderRadius: BorderRadius.circular(10),
                      //             color: Colors.blue,
                      //           )
                      //         : null,
                      //     child: ListTile(
                      //       key: Key('module-menu-${module.name}'),
                      //       leading: Icon(
                      //         module.icon,
                      //         color: isSelected ? Colors.white : null,
                      //       ),
                      //       title: Text(
                      //         module.title,
                      //         style: TextStyle(
                      //           color: isSelected ? Colors.white : null,
                      //         ),
                      //       ),
                      //       selected: isSelected,
                      //     ),
                      //   );
                      // }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}
