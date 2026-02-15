import 'package:cloud_functions/cloud_functions.dart';

class AiAssistantService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<String> sendMessage({
    required String message,
    required String screen,
  }) async {
    final callable = _functions.httpsCallable('chatWithGemini');
    final result = await callable.call<Map<String, dynamic>>({
      'message': message,
      'screen': screen,
    });
    final data = result.data;
    final reply = data['reply'] as String?;
    return reply ?? '';
  }
}

