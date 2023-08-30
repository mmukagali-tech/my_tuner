import 'package:flutter/material.dart';

// extension SpacerExtension on BuildContext {
//   Widget colSp(num height) => SizedBox(height: heightFrom(height));

//   Widget rowSp(num width) => SizedBox(width: widthFrom(width));
// }

extension SpacerExtensionFromNum on num {
  Widget colSp() => SizedBox(height: toDouble());

  Widget rowSp() => SizedBox(width: toDouble());
}
