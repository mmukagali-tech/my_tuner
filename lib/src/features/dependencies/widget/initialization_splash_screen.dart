import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_tuner/src/core/constants/themes.dart';

class InitializationSplashScreen extends StatelessWidget {
  const InitializationSplashScreen({required this.progress, super.key});

  final ValueListenable<({int progress, String message})> progress;

  @override
  Widget build(BuildContext context) {
    final theme = View.of(context).platformDispatcher.platformBrightness == Brightness.dark
        ? AppThemes.dark
        : AppThemes.light;
    return Theme(
      data: theme,
      child: Material(
        color: theme.scaffoldBackgroundColor,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                const CircularProgressIndicator.adaptive(),
                ValueListenableBuilder<({String message, int progress})>(
                  valueListenable: progress,
                  builder: (context, value, _) => Text(
                    '${value.progress}%',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      height: 1,
                      fontSize: 32,
                    ),
                  ),
                ),
                // RadialProgressIndicator(
                //   size: 128,
                //   child: ValueListenableBuilder<({String message, int progress})>(
                //     valueListenable: progress,
                //     builder: (context, value, _) => Text(
                //       '${value.progress}%',
                //       overflow: TextOverflow.ellipsis,
                //       maxLines: 1,
                //       textAlign: TextAlign.center,
                //       style: theme.textTheme.titleLarge?.copyWith(
                //         height: 1,
                //         fontSize: 32,
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 16),
                Opacity(
                  opacity: .25,
                  child: ValueListenableBuilder<({String message, int progress})>(
                    valueListenable: progress,
                    builder: (context, value, _) => Text(
                      value.message,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
