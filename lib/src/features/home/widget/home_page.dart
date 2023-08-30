import 'package:flutter/material.dart';
import 'package:my_tuner/src/core/constants/config.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Config.environment.name),
      ),
    );
  }
}
