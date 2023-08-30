import 'package:flutter/material.dart';

abstract class AppThemes {
  static ThemeData get light => ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: const ColorScheme.light(),
      );

  static ThemeData get dark => ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: const ColorScheme.dark(),
      );
}
