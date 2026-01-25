import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:process_run/shell.dart';

class VoiceEnrollmentPage extends StatefulWidget {
  const VoiceEnrollmentPage({super.key});

  @override
  State<VoiceEnrollmentPage> createState() => _VoiceEnrollmentPageState();
}

class _VoiceEnrollmentPageState extends State<VoiceEnrollmentPage> {
  final recorder = AudioRecorder();
  bool isRecording = false;
  String status = "🔴 جاهز للتسجيل";

  Future<void> _startRecording() async {
    final dir = Directory('/storage/emulated/0/Android/data/com.example.voice_id/files');
    final filePath = '${dir.path}/test_voice.wav';

    await recorder.start(
      const RecordConfig(encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1),
      path: filePath,
    );

    setState(() {
      isRecording = true;
      status = "🎙️ جاري التسجيل...";
    });
  }

  Future<void> _stopRecording() async {
    final dir = Directory('/storage/emulated/0/Android/data/com.example.voice_id/files');
    final filePath = '${dir.path}/test_voice.wav';

    await recorder.stop();
    setState(() {
      isRecording = false;
      status = "⏳ جاري استخراج بصمة الصوت...";
    });

    final shell = Shell();
    await shell.run('python3 android/tools/extract_mfcc.py "$filePath"');

    File('$filePath.json').copySync('assets/voice_embedding.json');

    setState(() {
      status = "✅ تم حفظ البصمة المرجعية!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(status, style: const TextStyle(color: Colors.white)),
            ElevatedButton(
              onPressed: isRecording ? _stopRecording : _startRecording,
              child: Text(isRecording ? "⏹️ إيقاف" : "🎙️ تسجيل"),
            ),
          ],
        ),
      ),
    );
  }
}
