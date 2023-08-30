import 'package:flutter/material.dart' show Locale, ThemeMode;
import 'package:my_tuner/src/core/storage/storage_key.dart';
import 'package:my_tuner/src/core/storage/storage_provider.dart';

abstract interface class SettingsRepository {
  Locale? getLocale();
  ThemeMode? getThemeMode();
  Future<void> setLocale(Locale value);
  Future<void> setThemeMode(ThemeMode value);
}

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._storageProvider);
  final StorageProvider _storageProvider;

  @override
  Locale? getLocale() => switch (_storageProvider.get<String>(StorageKey.locale)) {
        final String code => Locale(code),
        _ => null,
      };

  @override
  ThemeMode? getThemeMode() => switch (_storageProvider.get<int>(StorageKey.themeMode)) {
        final int index => ThemeMode.values.elementAt(index),
        _ => null,
      };

  @override
  Future<void> setLocale(Locale value) =>
      _storageProvider.setString(StorageKey.locale, value.languageCode);

  @override
  Future<void> setThemeMode(ThemeMode value) =>
      _storageProvider.setInt(StorageKey.themeMode, value.index);
}
