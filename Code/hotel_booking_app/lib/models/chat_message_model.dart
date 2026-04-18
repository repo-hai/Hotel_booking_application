enum MessageRole { user, assistant }

class ChatMessage {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  bool isLoading;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isLoading = false,
  });

  factory ChatMessage.loading() => ChatMessage(
        id: 'loading_${DateTime.now().millisecondsSinceEpoch}',
        role: MessageRole.assistant,
        content: '',
        timestamp: DateTime.now(),
        isLoading: true,
      );
}
