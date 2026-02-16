import 'dart:convert';
import 'package:http/http.dart' as http;

/// Submits code to Judge0 CE (Community Edition - Free Tier)
/// Replaces Piston API which became whitelist-only as of 2/15/2026
class Judge0Service {
  static const String baseUrl = 'https://judge0-ce.p.rapidapi.com';
  static const String rapidApiKey = 'REPLACE_WITH_YOUR_KEY'; // User needs to get free key from rapidapi.com
  
  // If no RapidAPI key, fallback to public Judge0 CE instance
  static const String fallbackUrl = 'https://ce.judge0.com';

  // Map app language codes to Judge0 language IDs
  static int _getLanguageId(String language) {
    switch (language.toLowerCase()) {
      case 'python':
        return 71; // Python 3.8.1
      case 'c':
        return 50; // C (GCC 9.2.0)
      case 'cpp':
      case 'c++':
        return 54; // C++ (GCC 9.2.0)
      case 'java':
        return 62; // Java (OpenJDK 13.0.1)
      case 'javascript':
        return 63; // JavaScript (Node.js 12.14.0)
      default:
        return 71; // Default to Python
    }
  }

  Future<Map<String, dynamic>> submitCode({
    required String language,
    required String sourceCode,
    required String stdin,
    required String expectedOutput,
  }) async {
    try {
      final languageId = _getLanguageId(language);
      
      // Try fallback URL first (no API key needed)
      final response = await http.post(
        Uri.parse('$fallbackUrl/submissions?base64_encoded=false&wait=true'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "language_id": languageId,
          "source_code": sourceCode,
          "stdin": stdin,
        }),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          return http.Response(
            jsonEncode({'error': 'Execution timeout'}),
            408,
          );
        },
      );

      if (response.statusCode == 408) {
        return {
          'status': {'description': 'Timeout', 'id': 0},
          'stdout': '',
          'stderr': 'Execution timeout after 15 seconds. Code may have infinite loop or be too slow.',
        };
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // Judge0 returns: { stdout, stderr, status: {id, description}, time, memory }
        final stdout = data['stdout'] ?? '';
        final stderr = data['stderr'] ?? '';
        final status = data['status'] ?? {};
        final statusId = status['id'] ?? 0;
        final statusDesc = status['description'] ?? 'Unknown';
        
        return {
          'stdout': stdout,
          'stderr': stderr,
          'status': {'description': statusDesc, 'id': statusId},
          'time': data['time'] ?? '0',
          'memory': data['memory'] ?? 0,
        };
      } else {
        return {
          'status': {'description': 'API Error ${response.statusCode}', 'id': 0},
          'stdout': '',
          'stderr': 'Execution failed. Judge0 CE returned ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': {'description': 'Exception', 'id': 0},
        'stdout': '',
        'stderr': 'Execution failed: $e',
      };
    }
  }
}
