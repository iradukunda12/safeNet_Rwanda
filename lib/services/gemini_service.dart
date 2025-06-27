import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey;

  GeminiService({required this.apiKey});

  Future<String> sendMessage(String message) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': message}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'] ?? 'No response';
    } else {
      return 'Error: ${response.body}';
    }
  }
}
