abstract final class Config {
  /// Environment flavor.
  /// e.g. development, staging, production
  static final EnvironmentFlavor environment = EnvironmentFlavor.from(
    const String.fromEnvironment('ENVIRONMENT', defaultValue: 'development'),
  );

  // --- Supabase service keys ---- //

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabeAPIKey = String.fromEnvironment('SUPABASE_API_KEY');
}

enum EnvironmentFlavor {
  development('development'),
  staging('staging'),
  production('production');

  const EnvironmentFlavor(this.value);

  factory EnvironmentFlavor.from(String? value) => switch (value?.trim().toLowerCase()) {
        'development' || 'debug' || 'develop' || 'dev' => development,
        'staging' || 'profile' || 'stage' || 'stg' => staging,
        'production' || 'release' || 'prod' || 'prd' => production,
        _ => const bool.fromEnvironment('dart.vm.product') ? production : development,
      };

  /// development, staging, production
  final String value;

  bool get isDevelopment => this == development;

  bool get isStaging => this == staging;

  bool get isProduction => this == production;
}
