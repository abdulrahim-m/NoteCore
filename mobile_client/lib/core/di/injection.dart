import 'package:get_it/get_it.dart';
import 'package:mobile_client/core/context/app_context.dart';
import 'package:mobile_client/core/storage/secure_storage_service.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<AppContext>(() => AppContext());
  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );

  // Feature Modules
  // initAuthFeature();
}
