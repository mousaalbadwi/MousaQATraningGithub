import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:process_run/shell.dart';

class VoiceVerificationService extends StatefulWidget {
  const VoiceVerificationService({super.key});

  @override
  State<VoiceVerificationService> createState() => _VoiceVerificationServiceState();
}

class _VoiceVerificationServiceState extends State<VoiceVerificationService> {
  final recorder = AudioRecorder();
  bool isRecording = false;
  String status = "🎧 جاهز للتحقق";
  String? verifyPath;

  Future<void> _recordAndVerify() async {
    final dir = Directory('/storage/emulated/0/Android/data/com.example.voice_id/files');
    String verifyPath = '${dir.path}/verify_voice.wav';

    await recorder.start(
      const RecordConfig(encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1),
      path: verifyPath,
    );

    setState(() {
      isRecording = true;
      status = "🎙️ جاري تسجيل صوت التحقق...";
    });

    await Future.delayed(const Duration(seconds: 3));
    await recorder.stop();

    final shell = Shell();
    await shell.run('python3 android/tools/extract_mfcc.py "$verifyPath"');

    final ref = jsonDecode(await File('assets/voice_embedding.json').readAsString());
    final ver = jsonDecode(await File('$verifyPath.json').readAsString());

    double similarity = _cosineSimilarity(ref.cast<double>(), ver.cast<double>());

    setState(() {
      status = similarity > 0.85
          ? "✅ الصوت متطابق (${(similarity * 100).toStringAsFixed(2)}%)"
          : "❌ الصوت غير متطابق (${(similarity * 100).toStringAsFixed(2)}%)";
    });
  }

  double _cosineSimilarity(List<double> a, List<double> b) {
    double dot = 0, aLen = 0, bLen = 0;
    for (int i = 0; i < a.length && i < b.length; i++) {
      dot += a[i] * b[i];
      aLen += a[i] * a[i];
      bLen += b[i] * b[i];
    }
    return dot / (sqrt(aLen) * sqrt(bLen));
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
              onPressed: isRecording ? null : _recordAndVerify,
              child: const Text("🔍 تحقق"),
            ),
          ],
        ),
      ),
    );
  }
}
