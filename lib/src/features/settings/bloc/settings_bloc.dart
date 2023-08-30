import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_tuner/src/features/settings/repository/settings_repository.dart';

part 'settings_bloc.freezed.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required Locale locale,
    required ThemeMode themeMode,
    required SettingsRepository settingsRepository,
  }) : super(_Idle(locale: locale, themeMode: themeMode)) {
    on<SettingsEvent>(
      (event, emit) async => event.map(
        changeLocale: (e) {
          emit(_Idle(locale: e.locale, themeMode: state.themeMode));
          return settingsRepository.setLocale(e.locale);
        },
        changeThemeMode: (e) {
          emit(_Idle(locale: state.locale, themeMode: e.mode));
          return settingsRepository.setThemeMode(e.mode);
        },
      ),
      transformer: droppable(),
    );
  }
}

@freezed
class SettingsEvent with _$SettingsEvent {
  const factory SettingsEvent.changeLocale(Locale locale) = _ChangeLocale;
  const factory SettingsEvent.changeThemeMode(ThemeMode mode) = _ChangeThemeMode;
}

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState.idle({
    required Locale locale,
    required ThemeMode themeMode,
  }) = _Idle;
}
