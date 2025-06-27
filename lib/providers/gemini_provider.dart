import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gemini_service.dart';

final geminiProvider = Provider<GeminiService>((ref) {
  return GeminiService(
    apiKey: 'AIzaSyDtsqbIWq1He573TSz1auaT7417kaLt0ec', // ✅ For testing only
  );
});
