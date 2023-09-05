import 'package:flutter/material.dart';

enum Guitar6String {
  e2,
  a2,
  d3,
  g3,
  b3,
  e4,
}

@immutable
abstract class Instrumentation {
  const Instrumentation();
}

@immutable
abstract class Tune {
  const Tune();
}

@immutable
final class StringTune extends Tune {
  const StringTune({
    required this.value,
    required this.interval,
  });
  final double value;
  final double interval;

  StringTune copyWith({
    double? value,
    double? interval,
  }) {
    return StringTune(
      value: value ?? this.value,
      interval: interval ?? this.interval,
    );
  }

  @override
  String toString() => 'StringTune(value: $value, interval: $interval)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StringTune && other.value == value && other.interval == interval;
  }

  @override
  int get hashCode => value.hashCode ^ interval.hashCode;
}

@immutable
sealed class AcousticGuitar extends Instrumentation {
  const AcousticGuitar({
    required this.e2,
    required this.a2,
    required this.d3,
    required this.g3,
    required this.b3,
    required this.e4,
  });

  final StringTune e2;
  final StringTune a2;
  final StringTune d3;
  final StringTune g3;
  final StringTune b3;
  final StringTune e4;
}

@immutable
class ClassicAcousticGuitar extends AcousticGuitar {
  const ClassicAcousticGuitar({
    super.e2 = const StringTune(value: 82.41, interval: 40),
    super.a2 = const StringTune(value: 110, interval: 50),
    super.d3 = const StringTune(value: 146.83, interval: 50),
    super.g3 = const StringTune(value: 196, interval: 50),
    super.b3 = const StringTune(value: 246.94, interval: 50),
    super.e4 = const StringTune(value: 329.63, interval: 50),
  });

  List<StringTune> get strings => [e2, a2, d3, g3, b3, e4];
}

@immutable
class DropDAcousticGuitar extends AcousticGuitar {
  const DropDAcousticGuitar({
    required super.e2,
    required super.a2,
    required super.d3,
    required super.g3,
    required super.b3,
    required super.e4,
  });
}

class OpenAAcousticGuitar extends AcousticGuitar {
  const OpenAAcousticGuitar({
    required super.e2,
    required super.a2,
    required super.d3,
    required super.g3,
    required super.b3,
    required super.e4,
  });
}
