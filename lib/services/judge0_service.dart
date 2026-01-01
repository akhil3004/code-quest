import 'dart:convert';
import 'package:http/http.dart' as http;

class Judge0Service {
  // Using public CE instance. 
  // If using RapidAPI, change baseUrl to 'https://judge0-ce.p.rapidapi.com' 
  // and add headers in _headers().
  static const String baseUrl = 'https://ce.judge0.com';
  
  static Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      // 'X-RapidAPI-Key': 'YOUR_KEY_HERE',
      // 'X-RapidAPI-Host': 'judge0-ce.p.rapidapi.com'
    };
  }

  static int _getLanguageId(String language) {
    switch (language.toLowerCase()) {
      case 'python': return 71; // Python 3.8.1
      case 'c': return 50;      // GCC 9.2.0
      case 'cpp': return 54;    // GCC 9.2.0
      case 'java': return 62;   // OpenJDK 13.0.1
      default: return 71;
    }
  }

  Future<Map<String, dynamic>> submitCode({
    required String language,
    required String sourceCode,
    required String stdin,
    required String expectedOutput,
  }) async {
    final uri = Uri.parse('$baseUrl/submissions?base64_encoded=true&wait=false');
    
    final encodedSource = base64Encode(utf8.encode(sourceCode));
    final encodedStdin = base64Encode(utf8.encode(stdin));
    final encodedExpected = base64Encode(utf8.encode(expectedOutput));
    
    try {
      final response = await http.post(
        uri,
        headers: _headers(),
        body: jsonEncode({
          'language_id': _getLanguageId(language),
          'source_code': encodedSource,
          'stdin': encodedStdin,
          'expected_output': encodedExpected,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return await _pollSubmission(data['token']);
      } else {
        throw Exception('Submission failed: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'status': {'id': 0, 'description': 'Error'},
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> _pollSubmission(String token) async {
    final uri = Uri.parse('$baseUrl/submissions/$token?base64_encoded=true');
    
    // Poll up to 10 times (10 seconds)
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(seconds: 1));
      try {
        final response = await http.get(uri, headers: _headers());
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final statusId = data['status']['id'];
          
          // Status IDs: 1 (In Queue), 2 (Processing)
          // Finished: 3 (Accepted), >3 (Error/Wrong)
          if (statusId >= 3) {
            return _decodeResult(data);
          }
        }
      } catch (e) {
        // Continue polling on transient network errors
      }
    }
    return {'status': {'id': 0, 'description': 'Timeout'}};
  }

  Map<String, dynamic> _decodeResult(Map<String, dynamic> data) {
    String decode(String? s) {
      if (s == null) return '';
      try {
        return utf8.decode(base64Decode(s.replaceAll('\n', '')));
      } catch (_) {
        return s;
      }
    }
    
    return {
      'status': data['status'], // {id, description}
      'stdout': decode(data['stdout']),
      'stderr': decode(data['stderr']),
      'compile_output': decode(data['compile_output']),
      'time': data['time'],
      'memory': data['memory'],
    };
  }
}
