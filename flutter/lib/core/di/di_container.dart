abstract class DIContainer {
  void registerSingleton<T extends Object>(T instance);
  void registerLazySingleton<T extends Object>(T Function() factory);
  T call<T extends Object>();
}
