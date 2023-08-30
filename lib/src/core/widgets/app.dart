import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_tuner/src/core/constants/themes.dart';
import 'package:my_tuner/src/core/localization/localization.dart';
import 'package:my_tuner/src/core/widgets/snackbars.dart';
import 'package:my_tuner/src/features/home/widget/home_page.dart';
import 'package:my_tuner/src/features/settings/widget/settings_scope.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScope(
      builder: (locale, themeMode) {
        return MaterialApp(
          scaffoldMessengerKey: AppSnackbars.scaffoldKey,
          title: 'My Tuner',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            Localization.delegate,
          ],
          supportedLocales: Localization.supportedLocales,
          locale: locale,
          theme: AppThemes.dark,
          darkTheme: AppThemes.dark,
          themeMode: themeMode,
          home: const HomePage(),
        );
      },
    );
  }
}
