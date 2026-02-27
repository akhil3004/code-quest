import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class AiAssistantService {
  // Web/desktop → localhost; Android emulator → 10.0.2.2 (tunnels to host)
  // For a real Android device, change 10.0.2.2 to your PC's local IP address.
  static String get _baseUrl =>
      kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';

  Future<String> sendMessage({
    required String message,
    required String screen,
    String userId = 'anonymous',
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': message,
              'screen': screen,
              'userId': userId,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return (data['reply'] as String?) ?? '';
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit reached. Please wait and try again.');
      } else if (response.statusCode == 403) {
        throw Exception('API key invalid or quota exceeded.');
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(data['error'] ?? 'AI generation failed');
      }
    } catch (e) {
      rethrow;
    }
  }
}

