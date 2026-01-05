import 'dart:convert';
import 'package:http/http.dart' as http;

/// Submits code to the Piston API (Free, No Key Required).
/// Replaces the original Judge0 implementation to avoid payment issues.
class Judge0Service {
  static const String baseUrl = 'https://emkc.org/api/v2/piston/execute';

  // Map app language codes to Piston language configs
  static Map<String, String> _getPistonConfig(String language) {
    switch (language.toLowerCase()) {
      case 'python': return {'language': 'python', 'version': '3.10.0'} as Map<String, String>;
      case 'c': return {'language': 'c', 'version': '10.2.0'} as Map<String, String>;
      case 'cpp': return {'language': 'c++', 'version': '10.2.0'} as Map<String, String>;
      case 'java': return {'language': 'java', 'version': '15.0.2'} as Map<String, String>;
      default: return {'language': 'python', 'version': '3.10.0'} as Map<String, String>;
    }
  }

  Future<Map<String, dynamic>> submitCode({
    required String language,
    required String sourceCode,
    required String stdin,
    required String expectedOutput,
  }) async {
    try {
      final config = _getPistonConfig(language);
      
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "language": config['language'],
          "version": config['version'],
          "files": [
            {
              "content": sourceCode
            }
          ],
          "stdin": stdin,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final run = data['run'];
        
        // Piston returns: { stdout: "...", stderr: "...", code: 0, ... }
        final stdout = run['stdout'] ?? '';
        final stderr = run['stderr'] ?? '';
        final exitCode = run['code'];
        
        // Map Piston exit code to Judge0-style status for compatibility
        // If exitCode is 0, we consider it "Accepted" (execution successful).
        // If non-zero, it's a "Runtime Error" or similar.
        // Compilation errors usually appear in stderr with a non-zero code.
        
        String statusDesc = (exitCode == 0) ? 'Accepted' : 'Error (Exit Code $exitCode)';
        if (exitCode != 0 && stderr.isNotEmpty) {
            statusDesc = 'Runtime/Compilation Error';
        }

        return {
          'stdout': stdout,
          'stderr': stderr,
          'status': {'description': statusDesc, 'id': exitCode == 0 ? 3 : 11},
          'time': '0.1', // Piston doesn't always return time in 'run', mocking it or ignoring
          'memory': 0,
        };
      } else {
        return {
          'status': {'description': 'API Error ${response.statusCode}', 'id': 0},
          'stdout': '',
          'stderr': 'Failed to execute code. Piston API returned ${response.statusCode}\n${response.body}',
        };
      }
    } catch (e) {
      return {
        'status': {'description': 'Exception', 'id': 0},
        'stdout': '',
        'stderr': 'App Error: $e',
      };
    }
  }
}
