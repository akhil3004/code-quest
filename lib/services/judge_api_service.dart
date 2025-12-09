import 'dart:convert';
import 'package:http/http.dart' as http;

class JudgeApiService {
  static const String baseUrl = 'https://ce.judge0.com';

  static int _languageId(String language) {
    switch (language.toLowerCase()) {
      case 'python':
        return 71;
      case 'c':
        return 50;
      default:
        throw ArgumentError('Unsupported language');
    }
  }

  static Future<Map<String, dynamic>> runCode(String language, String sourceCode) async {
    final langId = _languageId(language);
    final uri = Uri.parse('$baseUrl/submissions?base64_encoded=false&wait=true');
    final res = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'language_id': langId, 'source_code': sourceCode}),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return data;
    }
    throw Exception('Judge API error: ${res.statusCode}');
  }
}
