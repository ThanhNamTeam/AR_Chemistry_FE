import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/styles/app_colors.dart';
import '../../home/providers/theme_provider.dart';
import '../providers/chat_provider.dart';
import 'chat_message_bubble.dart';
import 'conversation_drawer.dart';

class AiChatPanel extends StatefulWidget {
  const AiChatPanel({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<AiChatPanel> createState() => _AiChatPanelState();
}

class _AiChatPanelState extends State<AiChatPanel> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int _lastMessageCount = 0;
  bool _lastSending = false;
  bool _lastLoadingHistory = false;

  @override
  void initState() {
    super.initState();
  }

  void _maybeScrollToBottom(ChatProvider chat) {
    final shouldScroll = chat.messages.length > _lastMessageCount ||
        (_lastSending && !chat.sending) ||
        (_lastLoadingHistory &&
            !chat.loadingHistory &&
            chat.messages.isNotEmpty);

    if (shouldScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    _lastMessageCount = chat.messages.length;
    _lastSending = chat.sending;
    _lastLoadingHistory = chat.loadingHistory;
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send(ChatProvider chat) async {
    final text = _inputCtrl.text;
    _inputCtrl.clear();
    await chat.sendMessage(text);
    _scrollToBottom();
    if (chat.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            chat.error!,
            style: const TextStyle(fontFamily: 'Inter'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      chat.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final chat = context.watch<ChatProvider>();
    _maybeScrollToBottom(chat);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.backgroundDark,
      drawer: const ConversationDrawer(),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Column(
          children: [
            _buildDragHandle(),
            _buildAppBar(chat),
            if (chat.error != null && !chat.sending) _buildErrorBanner(chat),
            Expanded(child: _buildMessageArea(chat)),
            _buildInputBar(chat),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(ChatProvider chat) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onClose,
            icon: Icon(Icons.close_rounded, color: AppColors.textPrimary),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.cyanEmeraldGradient,
            ),
            child: const Icon(Icons.science, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gia sư Hóa học AI',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  chat.sending
                      ? 'Đang suy nghĩ...'
                      : 'Hỏi về hóa học, phản ứng, nguyên tố',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            icon: Icon(Icons.history, color: AppColors.primary),
          ),
          IconButton(
            onPressed: chat.startNewConversation,
            icon: Icon(Icons.add, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(ChatProvider chat) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  chat.error!,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.error,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              GestureDetector(
                onTap: chat.clearError,
                child: Icon(Icons.close, size: 16, color: AppColors.error),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageArea(ChatProvider chat) {
    if (chat.loadingHistory) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(
              'Đang tải hội thoại...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    if (!chat.hasMessages && !chat.sending) {
      return _buildWelcome(chat);
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: chat.messages.length + (chat.sending ? 1 : 0),
      itemBuilder: (context, index) {
        if (chat.sending && index == chat.messages.length) {
          return const ChatTypingIndicator();
        }
        return ChatMessageBubble(message: chat.messages[index]);
      },
    );
  }

  Widget _buildWelcome(ChatProvider chat) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: const Icon(Icons.biotech, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            'Xin chào! Tôi là trợ lý hóa học',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hỏi về công thức, phản ứng, bảng tuần hoàn hoặc bài tập AR.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 24),
          ...ChatProvider.suggestedPrompts.map(
            (prompt) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SuggestionChip(
                text: prompt,
                onTap: () {
                  _inputCtrl.text = prompt;
                  _send(chat);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(ChatProvider chat) {
    final canSend = !chat.sending && _inputCtrl.text.trim().isNotEmpty;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottom),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: 0.92),
        border: Border(
          top: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _inputCtrl,
              minLines: 1,
              maxLines: 5,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Nhập câu hỏi hóa học...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter',
                ),
                filled: true,
                fillColor: AppColors.cardBg,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: AppColors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: AppColors.cardBorder.withValues(alpha: 0.6),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: chat.sending ? null : (_) => _send(chat),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: canSend ? () => _send(chat) : null,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: canSend ? AppColors.cyanEmeraldGradient : null,
                color: canSend ? null : AppColors.cardBg,
                shape: BoxShape.circle,
                border: canSend
                    ? null
                    : Border.all(color: AppColors.cardBorder),
              ),
              child: chat.sending
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Icon(
                      Icons.send_rounded,
                      color: canSend ? Colors.white : AppColors.textSecondary,
                      size: 22,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.cardBorder.withValues(alpha: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 18, color: AppColors.amber),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
