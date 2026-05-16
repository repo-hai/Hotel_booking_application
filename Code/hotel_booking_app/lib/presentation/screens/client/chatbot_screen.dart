import 'package:flutter/material.dart';
import '../../../models/chat_message_model.dart';
import '../../../services/chatbot_service.dart';
import '../../../theme/app_theme.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatbotService _chatbot = ChatbotService();
  final List<ChatMessage> _messages = [];
  bool _isSending = false;

  // Màu sắc theo design
  static const Color _userBubbleColor = Color(0xFFE8A23A);
  static const Color _botAvatarBlue = Color(0xFF3B5998);
  static const Color _botAvatarYellow = Color(0xFFFFC107);
  static const Color _onlineGreen = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        id: 'welcome',
        role: MessageRole.assistant,
        content:
            'Chào bạn! Mình là Trợ lý AI của Booking. Mình có thể giúp bạn tìm phòng, gợi ý lịch trình, hoặc giải đáp các thắc mắc về chuyến đi. Hôm nay bạn muốn đi đâu?',
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? prefilled]) async {
    final text = (prefilled ?? _controller.text).trim();
    if (text.isEmpty || _isSending) return;

    _controller.clear();

    setState(() {
      _messages.add(
        ChatMessage(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          role: MessageRole.user,
          content: text,
          timestamp: DateTime.now(),
        ),
      );
      _messages.add(ChatMessage.loading());
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final reply = await _chatbot.sendMessage(text);
      if (!mounted) return;
      setState(() {
        _messages.removeWhere((m) => m.isLoading);
        _messages.add(
          ChatMessage(
            id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
            role: MessageRole.assistant,
            content: reply,
            timestamp: DateTime.now(),
          ),
        );
        _isSending = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.removeWhere((m) => m.isLoading);
        _messages.add(
          ChatMessage(
            id: 'error_${DateTime.now().millisecondsSinceEpoch}',
            role: MessageRole.assistant,
            content: 'Xin lỗi, tôi gặp sự cố khi xử lý. Bạn thử lại nhé! 🙏',
            timestamp: DateTime.now(),
          ),
        );
        _isSending = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh, color: AppColors.primary),
              title: const Text('Làm mới cuộc trò chuyện'),
              onTap: () {
                Navigator.pop(ctx);
                _clearChat();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _chatbot.clearHistory();
      _messages.add(
        ChatMessage(
          id: 'welcome_new',
          role: MessageRole.assistant,
          content:
              'Cuộc trò chuyện đã được làm mới! 🔄\nMình có thể giúp gì cho bạn?',
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar "Chatbot AI"
            _buildTopBar(),
            // Profile header
            _buildProfileHeader(),
            // Chat area
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: _messages.length + 1, // +1 for date header
                itemBuilder: (context, index) {
                  if (index == 0) return _buildDateHeader();
                  return _buildMessageBubble(_messages[index - 1]);
                },
              ),
            ),
            // Input bar
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  // ─── Top bar ───
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.white,
      child: const Row(
        children: [
          Text(
            'Chatbot AI',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Profile header ───
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
          // Bot avatar
          _buildBotAvatarLarge(),
          const SizedBox(width: 10),
          // Name + status
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trợ lý AI Booking',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    CircleAvatar(radius: 4, backgroundColor: _onlineGreen),
                    SizedBox(width: 5),
                    Text(
                      'Đang hoạt động',
                      style: TextStyle(
                        fontSize: 12,
                        color: _onlineGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Menu
          GestureDetector(
            onTap: _showMenu,
            child: const Icon(
              Icons.more_vert,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bot avatar (large - header) ───
  Widget _buildBotAvatarLarge() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: _botAvatarBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.smart_toy, color: AppColors.white, size: 22),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _botAvatarYellow,
                shape: BoxShape.circle,
                border: Border.all(color: _botAvatarBlue, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bot avatar (small - in chat) ───
  Widget _buildBotAvatarSmall() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: _botAvatarBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.smart_toy, color: AppColors.white, size: 16),
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: _botAvatarYellow,
                shape: BoxShape.circle,
                border: Border.all(color: _botAvatarBlue, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Date header ───
  Widget _buildDateHeader() {
    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Hôm nay $time',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ─── Message bubble ───
  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.role == MessageRole.user;

    // Loading indicator
    if (message.isLoading) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildBotAvatarSmall(),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                  bottomLeft: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const _TypingIndicator(),
            ),
          ],
        ),
      );
    }

    // User message
    if (isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: _userBubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Text(
              message.content,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.white,
                height: 1.45,
              ),
            ),
          ),
        ),
      );
    }

    // Bot message
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: _buildBotAvatarSmall(),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                  bottomLeft: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Input bar ───
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          // "+" button
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.textSecondary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Text field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                maxLines: 4,
                minLines: 1,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Send button
          GestureDetector(
            onTap: _isSending ? null : () => _sendMessage(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isSending
                    ? AppColors.textSecondary.withOpacity(0.3)
                    : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: AppColors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Typing indicator (3 dots animation) ───
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.2;
            final t = (_ctrl.value - delay).clamp(0.0, 1.0);
            final y = -4.0 * (1.0 - (2.0 * t - 1.0) * (2.0 * t - 1.0));
            return Container(
              margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
              child: Transform.translate(
                offset: Offset(0, y),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
