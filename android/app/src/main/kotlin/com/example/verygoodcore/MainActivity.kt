package com.example.verygoodcore.my_tuner

import android.Manifest
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.nio.ByteBuffer
import java.util.concurrent.atomic.AtomicBoolean

class MainActivity: FlutterActivity() {

    private lateinit var audioRecord: AudioRecord
    private lateinit var audioThread: Thread
    private var isRecording = AtomicBoolean(false)
    var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "audio_channel/methods")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startRecording" -> {
                        val isPermitted =  ActivityCompat.checkSelfPermission(
                            this,
                            Manifest.permission.RECORD_AUDIO
                        ) == PackageManager.PERMISSION_GRANTED

                        if (!isPermitted) {
                            requestPermission()
//                            result.error(
//                                "NOT_PERMITTED",
//                                "Microphone was not permitted",
//                                null,
//                            )
                        } else {
                            if (!isRecording.get()) {
                                startRecording()
                                result.success(null)
                            } else {
                                result.error(
                                    "ALREADY_RECORDING",
                                    "Recording is already in progress.",
                                    null
                                )
                            }
                        }
                    }
                    "stopRecording" -> {
                        if (isRecording.get()) {
                            stopRecording()
                            result.success(null)
                        } else {
                            result.error(
                                "NOT_RECORDING",
                                "Recording is not in progress.",
                                null
                            )
                        }
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "audio_channel/events")
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    this@MainActivity.eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })

    }

    private fun startRecording() {
        val bufferSize = AudioRecord.getMinBufferSize(
            44100,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
        )

        val isPermitted =  ActivityCompat.checkSelfPermission(
            this,
            Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED

        if (!isPermitted) return

        audioRecord = AudioRecord(
            MediaRecorder.AudioSource.MIC,
            44100,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
            bufferSize,
        )

        audioRecord.startRecording()
        isRecording.set(true)

        audioThread = Thread {
            val buffer = ShortArray(bufferSize)
            val byteBuffer = ByteBuffer.allocate(bufferSize * 2)
            while (isRecording.get()) {
                val readSize = audioRecord.read(buffer, 0, bufferSize)
                if (readSize > 0) {
                    byteBuffer.clear()
                    byteBuffer.asShortBuffer().put(buffer, 0, readSize)

                    runOnUiThread {
                        eventSink?.success(byteBuffer.array())
                    }
                }
            }
        }
        audioThread.start()
    }

    private fun stopRecording() {
        isRecording.set(false)
        audioThread.join()
        audioRecord.stop()
        audioRecord.release()
    }

    private fun requestPermission() {
        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.RECORD_AUDIO),
            100
        )
    }
}
