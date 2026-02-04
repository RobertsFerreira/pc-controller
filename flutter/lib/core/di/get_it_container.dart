import 'package:get_it/get_it.dart';

import 'di_container.dart';

class GetItContainer implements DIContainer {
  final GetIt _getIt = GetIt.instance;

  @override
  T call<T extends Object>() => _getIt.call<T>();

  @override
  void registerSingleton<T extends Object>(T instance) {
    _getIt.registerSingleton<T>(instance);
  }

  @override
  void registerLazySingleton<T extends Object>(T Function() factory) {
    _getIt.registerLazySingleton<T>(factory);
  }
}
