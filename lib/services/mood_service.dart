import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/mood.dart';
import 'api_config.dart';

// Atelier 10 pattern: HTTP POST to REST API, parse JSON response
class MoodService {
  // Maps Luxand actual emotion names to our MoodType enum
  static const Map<String, MoodType> _emotionMap = {
    'happy': MoodType.happy,
    'sad': MoodType.sad,
    'angry': MoodType.angry,
    'neutral': MoodType.calm,
    'fear': MoodType.sad,
    'surprise': MoodType.energetic,
    'disgust': MoodType.angry,
  };

  Future<MoodResult> detectMood(File imageFile) async {
    try {
      // Build multipart POST request (Atelier 10: HTTP request with file)
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.luxandEmotionsUrl),
      );
      request.headers['token'] = ApiConfig.luxandToken;
      request.files.add(
        await http.MultipartFile.fromPath('photo', imageFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Log the raw response before any parsing
      debugPrint('[MOOD] HTTP status: ${response.statusCode}');
      debugPrint('[MOOD] Raw body: ${response.body}');

      // Atelier 10: check status code before parsing
      if (response.statusCode == 401) {
        throw Exception('Invalid API token');
      }
      if (response.statusCode != 200) {
        throw Exception('Server error (${response.statusCode})');
      }

      // Atelier 10: jsonDecode wrapped defensively — never cast blindly
      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        throw Exception('Invalid response from server');
      }

      if (decoded is! Map) {
        throw Exception('Unexpected response format');
      }

      final status = decoded['status'];
      if (status != 'success') {
        throw Exception(
            'Detection failed: ${decoded['message'] ?? status ?? 'unknown error'}');
      }

      final faces = decoded['faces'];
      if (faces == null || faces is! List || faces.isEmpty) {
        throw Exception(
            'No face detected — make sure your face is clearly visible and well lit');
      }

      final firstFace = faces[0];
      if (firstFace is! Map) {
        throw Exception('Unexpected face data');
      }

      // Field is 'emotion' (singular) in the actual Luxand response
      final emotion = firstFace['emotion'];
      if (emotion == null || emotion is! Map || emotion.isEmpty) {
        throw Exception('Could not read emotions from the photo');
      }

      // Safely convert scores to Map<String, double> (values are 0-100 percentages)
      final emotionScores = <String, double>{};
      emotion.forEach((key, value) {
        if (key is String && value != null) {
          emotionScores[key] = (value as num).toDouble();
        }
      });

      // Use dominant_emotion field if present, otherwise compute from scores
      final dominantName = (firstFace['dominant_emotion'] is String &&
              (firstFace['dominant_emotion'] as String).isNotEmpty)
          ? firstFace['dominant_emotion'] as String
          : emotionScores.entries
              .reduce((a, b) => a.value >= b.value ? a : b)
              .key;

      final dominantScore = emotionScores[dominantName] ?? 0.0;
      // Scores are 0-100; divide by 100 to get 0.0-1.0 for MoodResult.confidence
      final confidence = (dominantScore / 100.0).clamp(0.0, 1.0);

      final mappedMood = _emotionMap[dominantName] ?? MoodType.calm;
      debugPrint(
          '[MOOD] dominant: $dominantName score: $dominantScore confidence: $confidence -> ${mappedMood.name}');

      return MoodResult(
        mood: mappedMood,
        confidence: confidence,
        detectedAt: DateTime.now(),
      );
    } on SocketException {
      throw Exception('Network error — check your connection');
    } on Exception {
      rethrow;
    }
  }
}
