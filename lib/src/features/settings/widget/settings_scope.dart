import 'package:flutter/material.dart'
    show BuildContext, InheritedWidget, Locale, State, StatefulWidget, ThemeMode, Widget;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tuner/src/core/extensions/context_extensions.dart';
import 'package:my_tuner/src/features/settings/bloc/settings_bloc.dart';

class SettingsScope extends StatefulWidget {
  const SettingsScope({required this.builder, super.key});
  final Widget Function(Locale, ThemeMode) builder;

  static SettingsBloc blocOf(BuildContext context) => _SettingsScope.of(context).bloc;
  static Locale localeOf(BuildContext context, {bool listen = true}) =>
      _SettingsScope.of(context, listen: listen).locale;
  static ThemeMode themeModeOf(BuildContext context, {bool listen = true}) =>
      _SettingsScope.of(context, listen: listen).themeMode;

  @override
  State<SettingsScope> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsScope> {
  late SettingsBloc bloc;

  @override
  void initState() {
    super.initState();
    final settingsRepository = context.dependencies.settingsRepository;
    bloc = SettingsBloc(
      locale: settingsRepository.getLocale() ?? const Locale('en'),
      themeMode: settingsRepository.getThemeMode() ?? ThemeMode.system,
      settingsRepository: settingsRepository,
    );
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      bloc: bloc,
      builder: (context, state) {
        return _SettingsScope(
          bloc: bloc,
          locale: state.locale,
          themeMode: state.themeMode,
          child: widget.builder(state.locale, state.themeMode),
        );
      },
    );
  }
}

class _SettingsScope extends InheritedWidget {
  const _SettingsScope({
    required super.child,
    required this.bloc,
    required this.locale,
    required this.themeMode,
  });
  final SettingsBloc bloc;
  final Locale locale;
  final ThemeMode themeMode;

  static _SettingsScope of(BuildContext context, {bool listen = false}) {
    final inheritedWidget = listen
        ? context.dependOnInheritedWidgetOfExactType<_SettingsScope>()
        : context.getElementForInheritedWidgetOfExactType<_SettingsScope>()?.widget
            as _SettingsScope?;

    if (inheritedWidget == null) {
      throw Exception(
        'Unable to locate _SettingsScope. '
        'Either it was not declared as an ancestor '
        'of the widget that has tried to access it, or BuildContext does not '
        'contain its instance.',
      );
    }

    return inheritedWidget;
  }

  @override
  bool updateShouldNotify(_SettingsScope oldWidget) =>
      locale != oldWidget.locale || themeMode != oldWidget.themeMode;
}
