import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:fftea/fftea.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:my_tuner/src/core/constants/themes.dart';
import 'package:my_tuner/src/core/localization/localization.dart';
import 'package:my_tuner/src/core/widgets/snackbars.dart';
// import 'package:my_tuner/src/features/guitar/widget/home_page.dart';
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

const sampleRate = 48000;
const windowSize = 48000;
const windowStep = 12000;
const numHps = 5;
const powerTrash = 1e-6;
const conceptPitch = 440;
const whiteNoiseTrash = 0.2;
const windowTLen = windowSize / sampleRate;
const sampleTLen = 1 / sampleRate;
const deltaFreq = sampleRate / windowSize;
const octaveBands = [50, 100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600];

void entryPoint(SendPort send2main) {
  final rcvPort = ReceivePort();
  send2main.send(rcvPort.sendPort);

  rcvPort.listen((message) {
    if (message is! List<int>) return;
    final frequency = detectPitch(message);
    send2main.send(frequency);
  });
}

final hannWindow = Window.hanning(windowSize);

double detectPitch(List<int> samples) {
  final signalPower =
      samples.map((sample) => sample * sample).reduce((a, b) => a + b) / samples.length;

  if (signalPower < powerTrash) return sampleRate.toDouble();

  var chunk = <int>[];
  for (var i = 0; i < samples.length; i += samples.length) {
    chunk = samples.sublist(i, i + samples.length);
  }

  // if (chunk.length != hannWindow.length) return sampleRate.toDouble();
  final hannSamples = chunk.mapIndexed((index, element) => element * hannWindow[index]).toList();

  final complexSamples = ComplexArray.fromRealArray(hannSamples);
  final fft = FFT(complexSamples.length);

  final spectrum = fft.realInverseFft(complexSamples);

  for (var i = 0; i < 62 ~/ (sampleRate / windowSize); i++) {
    spectrum[i] = 0;
  }

  for (var j = 0; j < octaveBands.length - 1; j++) {
    final indStart = octaveBands[j] ~/ deltaFreq;
    final indEnd = octaveBands[j + 1] ~/ deltaFreq;
    final indEndClamped = indEnd < spectrum.length ? indEnd : spectrum.length;

    var avgEnergyPerFreq = 0.0;
    for (var i = indStart; i < indEndClamped; i++) {
      avgEnergyPerFreq += spectrum[i] * spectrum[i];
    }
    avgEnergyPerFreq /= indEndClamped - indStart;
    avgEnergyPerFreq = math.sqrt(avgEnergyPerFreq);

    for (var i = indStart; i < indEndClamped; i++) {
      spectrum[i] = spectrum[i] > whiteNoiseTrash * avgEnergyPerFreq ? spectrum[i] : 0.0;
    }
  }

  // interpolate spectrum
  final outputLength = spectrum.length * numHps;
  final magSpecIpol = List<double>.filled(outputLength, 0);

  for (var i = 0; i < spectrum.length; i++) {
    final inputIndex = i.toDouble();
    final outputIndex = (inputIndex * numHps).toInt();
    magSpecIpol[outputIndex] = spectrum[i];
  }

  // calculate the hps
  var hpsSpec = List<double>.from(spectrum);

  for (var i = 0; i < numHps; i++) {
    final tmpHpsSpec = <double>[];

    for (var j = 0; j < (magSpecIpol.length / (i + 1)).ceil(); j++) {
      if (hpsSpec.length <= j) break;
      tmpHpsSpec.add(hpsSpec[j] * magSpecIpol[j * (i + 1)]);
    }

    if (!tmpHpsSpec.any((value) => value != 0.0)) {
      break;
    }

    hpsSpec = tmpHpsSpec;
  }

  final maxInd = hpsSpec.indexOf(hpsSpec.reduce((a, b) => a.abs() > b.abs() ? a : b));
  final maxFreq = maxInd * (sampleRate / windowSize) / numHps;

  return maxFreq;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final frequencyStream = StreamController<double>();

  late Stream<Uint8List?>? stream;
  StreamSubscription<Uint8List>? subscription;

  @override
  void initState() {
    super.initState();
    setupIsolates();
  }

  @override
  void dispose() {
    subscription?.cancel();
    frequencyStream.close();
    isolate.kill();
    rcvPort.close();
    super.dispose();
  }

  late Isolate isolate;
  late ReceivePort rcvPort;
  late SendPort send2Isolate;

  Future<void> setupIsolates() async {
    rcvPort = ReceivePort();
    isolate = await Isolate.spawn(
      entryPoint,
      rcvPort.sendPort,
      debugName: 'MyIso',
    );

    final completer = Completer<SendPort>();
    rcvPort.listen((message) {
      if (message is SendPort) completer.complete(message);
      if (message is double) frequencyStream.sink.add(message);
    });

    send2Isolate = await completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tuner'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                MicStream.microphone(
                  audioFormat: AudioFormat.ENCODING_PCM_16BIT,
                  sampleRate: sampleRate,
                ).then((value) async {
                  stream = value;
                  if (value == null) return print('Microphone do not work');

                  await subscription?.cancel();
                  subscription = value.listen((data) => send2Isolate.send(data));
                });
              },
              child: const Text('START'),
            ),
            StreamBuilder(
              stream: frequencyStream.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data.toString());
                } else {
                  return const Text('No data');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
