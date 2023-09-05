import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:my_tuner/src/core/constants/config.dart';
import 'package:my_tuner/src/features/guitar/enums/guitar_string.dart';

// Teest
void entryPoint(SendPort send2main) {
  final rcvPort = ReceivePort();
  send2main.send(rcvPort.sendPort);

  rcvPort.listen((message) {
    if (message is! (List<int>, double)) return;
    final frequency = detectPitch(message.$1, message.$2);
    send2main.send(frequency);
  });
}

double detectPitch(List<int> audioSamples, double sampleRate) {
  var maxCorrelation = 0;
  var maxDelay = 0;

  // Autocorrelation function
  for (var delay = 1; delay < audioSamples.length; delay++) {
    // Start from delay = 1
    var correlation = 0;

    for (var i = 0; i < audioSamples.length - delay; i++) {
      correlation += (audioSamples[i] - 128) * (audioSamples[i + delay] - 128);
    }

    if (correlation > maxCorrelation) {
      maxCorrelation = correlation;
      maxDelay = delay;
    }
  }

  // Calculate frequency from the delay
  final fundamentalFreq = sampleRate / maxDelay;

  return fundamentalFreq;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final streamController = StreamController<double>();
  StreamSubscription<Uint8List>? subscription;
  StringTune? selected;
  static const guitar = ClassicAcousticGuitar();

  Future<void> change(StringTune? value) async {
    try {
      selected = value;

      await MicStream.microphone(
        audioFormat: AudioFormat.ENCODING_PCM_16BIT,
      ).then((stream) async {
        if (stream == null) return print('Microphone do not work');

        await subscription?.cancel();
        subscription = stream.listen((data) => send2Isolate.send((data, selected?.value)));
        setState(() {});
      });
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  void stopRecording() => subscription?.cancel();

  @override
  void initState() {
    super.initState();
    setupIsolates();
  }

  @override
  void dispose() {
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
      if (message is double) streamController.sink.add(message);
    });

    send2Isolate = await completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(Config.environment.name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: guitar.strings.map((e) {
                return Checkbox(
                  value: selected == e,
                  onChanged: (v) {
                    if (v == null || !v) return;
                    change(e);
                  },
                );
              }).toList(),
            ),
            StreamBuilder(
              stream: streamController.stream,
              builder: (context, snapshot) {
                final data = snapshot.data;
                if (data == null) return const SizedBox();

                return Text(
                  'Detected pitch: $data Hz',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
