import 'package:flutter/material.dart';

abstract class AppSnackbars {
  static GlobalKey<ScaffoldMessengerState> get scaffoldKey => GlobalKey<ScaffoldMessengerState>();

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showError(
    BuildContext context,
    String message, {
    bool root = false,
  }) {
    final snackbar = SnackBar(content: Text(message));
    return switch (root) {
      true => scaffoldKey.currentState?.showSnackBar(snackbar),
      false => ScaffoldMessenger.of(context).showSnackBar(snackbar),
    };
  }

  static void clear(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    scaffoldKey.currentState?.clearSnackBars();
  }
}
