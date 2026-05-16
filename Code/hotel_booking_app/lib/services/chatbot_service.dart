import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ChatbotService {
  // RAG server URL (chatbot_server.py)
  static String get _serverUrl {
    if (kIsWeb) return 'http://localhost:8000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    } catch (_) {}
    return 'http://localhost:8000';
  }

  final String _sessionId;

  ChatbotService()
      : _sessionId =
            'session_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';

  Future<String> sendMessage(String userMessage) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_serverUrl/chat'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'message': userMessage,
              'session_id': _sessionId,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return (data['reply'] as String).trim();
      } else {
        final data = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(data['detail'] ?? 'Lỗi server');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearHistory() async {
    try {
      await http
          .post(
            Uri.parse('$_serverUrl/chat/clear?session_id=$_sessionId'),
          )
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
  }
}
