import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:l/l.dart';
import 'package:my_tuner/src/core/bloc/bloc_observer.dart';
import 'package:my_tuner/src/core/storage/storage_provider.dart';
import 'package:my_tuner/src/features/dependencies/model/dependencies.dart';
import 'package:my_tuner/src/features/settings/repository/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef _InitializationStep = FutureOr<void> Function(
  _MutableDependencies dependencies,
);

class _MutableDependencies implements Dependencies {
  @override
  late final StorageProvider storageProvider;

  @override
  late final SettingsRepository settingsRepository;

  /*
  @override
  late final APITokensRepository apiTokensRepository;

  @override
  late final AuthenticationInterceptor authenticationInterceptor;

  @override
  late final APIClient apiClient;

  @override
  late final NetworkProvider networkProvider;

  @override
  late final NetworkExecuter networkExecuter;

  @override
  late final AuthenticationRepository authenticationRepository;

  @override
  late final AppRouter router;
  */
}

mixin InitializeDependencies {
  /// Initializes the app and returns a [Dependencies] object
  Future<Dependencies> initializeDependencies({
    void Function(int progress, String message)? onProgress,
  }) async {
    final steps = _initializationSteps;
    final dependencies = _MutableDependencies();
    final totalSteps = steps.length;
    for (var currentStep = 0; currentStep < totalSteps; currentStep++) {
      final step = steps[currentStep];
      final percent = (currentStep * 100 ~/ totalSteps).clamp(0, 100);
      onProgress?.call(percent, step.$1);
      l.v6(
        'Initialization | $currentStep/$totalSteps ($percent%) | "${step.$1}"',
      );
      await step.$2(dependencies);
    }
    return dependencies;
  }
}

List<(String, _InitializationStep)> get _initializationSteps => <(String, _InitializationStep)>[
      (
        'Observer state managment',
        (_) => Bloc.observer = AppBlocObserver(),
      ),
      (
        'Initializing analytics',
        (_) {},
      ),
      (
        'Log app open',
        (_) {},
      ),
      (
        'Get remote config',
        (_) {},
      ),
      (
        'Storage provider',
        (dependencies) async => dependencies.storageProvider =
            SharedPreferencesStorageProvider(await SharedPreferences.getInstance()),
      ),
      (
        'Settings repository',
        (dependencies) =>
            dependencies.settingsRepository = SettingsRepositoryImpl(dependencies.storageProvider),
      ),
      /*
      (
        'API Tokens repository',
        (dependencies) => dependencies.apiTokensRepository =
            APITokensRepositoryImpl(storageProvider: dependencies.storageProvider),
      ),
      (
        'Authentication interceptor provider',
        (dependencies) => dependencies.authenticationInterceptor =
            AuthenticationInterceptor(dependencies.apiTokensRepository),
      ),
      (
        'API client',
        (dependencies) {
          final dio = Dio(
            BaseOptions(
              baseUrl: Config.apiBaseUrl,
              connectTimeout: Config.apiConnectTimeout,
              receiveTimeout: Config.apiReceiveTimeout,
              contentType: Headers.jsonContentType,
              validateStatus: (status) => status != null && status ~/ 100 == 2,
            ),
          )..interceptors.addAll([
              dependencies.authenticationInterceptor,
              LogInterceptor(requestBody: true, responseBody: true),
            ]);
          dependencies.apiClient = DioAPIClient(dio: dio);
        },
      ),
      (
        'Network provider',
        (dependencies) =>
            dependencies.networkProvider = APINetworkProvider(client: dependencies.apiClient),
      ),
      (
        'Network executer',
        (dependencies) => dependencies.networkExecuter = const NetworkExecuter(),
      ),
      (
        'Authentication repository',
        (dependencies) {
          final repository = AuthenticationRepositoryImpl(
            storageProvider: dependencies.storageProvider,
          );

          dependencies.authenticationInterceptor.onSessionExpired = repository.emergencyLogout;

          dependencies.authenticationRepository = repository..init();
        },
      ),
      (
        'App router',
        (dependencies) {
          final isAuthenticated = dependencies.authenticationRepository.user
              .map(authorized: (_) => true, unauthorized: (_) => false);
          final appState = AppState(
            authenticated: isAuthenticated,
            userChanges: dependencies.authenticationRepository.userChanges,
          );
          final routerDelegate = AppRouterDelegate(appState);
          final backButtonDispatcher = AppRouterBackButtonDispatcher(routerDelegate);
          final routerParser = AppRouterParser(appState, debugRoute: kDebugMode);
          final router = AppRouterImpl(
            appState: appState,
            appRouterDelegate: routerDelegate,
            appRouterBackButtonDispatcher: backButtonDispatcher,
            appRouterParser: routerParser,
          );
          dependencies.router = router;
        },
      ),
      */
    ];
