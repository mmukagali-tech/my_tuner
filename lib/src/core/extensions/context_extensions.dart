import 'package:flutter/material.dart'
    show BuildContext, EdgeInsets, MediaQuery, Size, Theme, ThemeData;
import 'package:my_tuner/src/features/dependencies/model/dependencies.dart';
import 'package:my_tuner/src/features/dependencies/widget/dependencies_scope.dart';

extension BuildContextExtensions on BuildContext {
  Dependencies get dependencies => DependenciesScope.of(this);

  ThemeData get theme => Theme.of(this);

  Size get mqSize => MediaQuery.sizeOf(this);
  EdgeInsets get mqPadding => MediaQuery.paddingOf(this);
  EdgeInsets get mqViewInsets => MediaQuery.viewInsetsOf(this);
}
