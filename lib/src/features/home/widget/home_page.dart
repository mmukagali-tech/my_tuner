import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_tuner/src/core/constants/config.dart';

void entryPoint(SendPort send2main) {
  final rcvPort = ReceivePort();
  send2main.send(rcvPort.sendPort);

  rcvPort.listen((message) {
    if (message is! List<int>) return;
    final frequency = detectPitch(message);
    send2main.send(frequency);
  });
}

double detectPitch(List<int> audioSamples, [int sampleRate = 44100]) {
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
  static const platform = MethodChannel('audio_channel/methods');
  static const eventChannel = EventChannel('audio_channel/events');

  final streamController = StreamController<double>();

  Future<void> startRecording() async {
    try {
      await platform.invokeMethod('startRecording');
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      await platform.invokeMethod('stopRecording');
    } catch (e) {
      print('Error on stopping recording: $e');
    }
  }

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

    final send2Isolate = await completer.future;

    eventChannel.receiveBroadcastStream().listen((event) {
      if (event is List<int>) send2Isolate.send(event);
    });
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
            ElevatedButton(
              onPressed: startRecording,
              child: const Text('Start'),
            ),
            ElevatedButton(
              onPressed: stopRecording,
              child: const Text('Stop'),
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
