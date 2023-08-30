import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:l/l.dart';
import 'package:my_tuner/src/core/utils/logger_util.dart';
import 'package:my_tuner/src/core/widgets/app.dart';
import 'package:my_tuner/src/features/dependencies/initialization/initialization.dart';
import 'package:my_tuner/src/features/dependencies/widget/dependencies_scope.dart';
import 'package:my_tuner/src/features/dependencies/widget/initialization_splash_screen.dart';

void main() => l.capture<void>(
      () => runZonedGuarded(
        () {
          final initialization = InitializationExecutor();
          runApp(
            DependenciesScope(
              initialization: initialization(),
              splashScreen: InitializationSplashScreen(
                progress: initialization,
              ),
              child: const App(),
            ),
          );
        },
        l.e,
      ),
      const LogOptions(messageFormatting: LoggerUtil.messageFormatting),
    );
