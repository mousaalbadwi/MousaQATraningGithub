import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

Future<List<double>> loadVoiceEmbeddingFromAssets() async {
  String jsonString = await rootBundle.loadString('assets/voice_embedding.json');
  List<dynamic> jsonData = jsonDecode(jsonString);
  return jsonData.map((e) => (e is num) ? e.toDouble() : 0.0).toList();
}
