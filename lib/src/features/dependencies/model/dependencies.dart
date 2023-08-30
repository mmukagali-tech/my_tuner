import 'package:my_tuner/src/core/storage/storage_provider.dart';
import 'package:my_tuner/src/features/settings/repository/settings_repository.dart';

abstract interface class Dependencies {
  abstract final StorageProvider storageProvider;

  abstract final SettingsRepository settingsRepository;

  // abstract final APITokensRepository apiTokensRepository;

  // abstract final AuthenticationInterceptor authenticationInterceptor;

  // abstract final APIClient apiClient;

  // abstract final NetworkProvider networkProvider;

  // abstract final NetworkExecuter networkExecuter;

  // abstract final AuthenticationRepository authenticationRepository;

  // abstract final AppRouter router;
}
