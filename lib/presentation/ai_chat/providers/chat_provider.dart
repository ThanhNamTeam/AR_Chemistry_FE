import 'package:flutter/foundation.dart';

import '../../../core/api/ai_api_service.dart';
import '../../../domain/models/ai_chat_models.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider({AiApiService? api}) : _api = api ?? AiApiService();

  final AiApiService _api;

  final List<ChatMessage> _messages = [];
  List<ConversationSummary> _conversations = [];

  String? _conversationId;
  bool _sending = false;
  bool _loadingHistory = false;
  bool _loadingConversations = false;
  String? _error;

  /// Tin nhắn gửi thất bại gần nhất — để nút "Thử lại" gửi lại được mà người
  /// dùng không phải gõ lại.
  String? _lastFailedMessage;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  List<ConversationSummary> get conversations => List.unmodifiable(_conversations);
  String? get conversationId => _conversationId;
  bool get sending => _sending;
  bool get loadingHistory => _loadingHistory;
  bool get loadingConversations => _loadingConversations;
  String? get error => _error;
  bool get hasMessages => _messages.isNotEmpty;
  bool get canRetry => _lastFailedMessage != null;

  static const suggestedPrompts = [
    'Giải thích cấu trúc phân tử nước H₂O',
    'Sự khác nhau giữa ion và nguyên tử?',
    'Phản ứng axit–bazơ là gì?',
    'Bảng tuần hoàn có bao nhiêu nhóm?',
  ];

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadConversations() async {
    _loadingConversations = true;
    notifyListeners();
    try {
      _conversations = await _api.getConversations();
      _error = null;
    } on AiApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Không tải được lịch sử chat.';
    } finally {
      _loadingConversations = false;
      notifyListeners();
    }
  }

  Future<void> openConversation(String id) async {
    _conversationId = id;
    _loadingHistory = true;
    _messages.clear();
    notifyListeners();
    try {
      _messages.addAll(await _api.getConversationMessages(id));
      _error = null;
    } on AiApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Không tải được hội thoại.';
    } finally {
      _loadingHistory = false;
      notifyListeners();
    }
  }

  void startNewConversation() {
    _conversationId = null;
    _messages.clear();
    _error = null;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _sending) return;

    final userMsg = ChatMessage(
      id: 'local-user-${DateTime.now().millisecondsSinceEpoch}',
      role: ChatMessageRole.user,
      content: trimmed,
      createdAt: DateTime.now(),
    );
    _messages.add(userMsg);
    _sending = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.sendMessage(
        message: trimmed,
        conversationId: _conversationId,
      );
      _conversationId = result.conversationId;
      _messages.add(
        ChatMessage(
          id: 'local-ai-${DateTime.now().millisecondsSinceEpoch}',
          role: ChatMessageRole.assistant,
          content: result.answer,
          createdAt: result.timestamp ?? DateTime.now(),
          modelUsed: result.modelUsed,
          reusedMemory: result.reusedMemory,
          similarityScore: result.similarityScore,
        ),
      );
      _lastFailedMessage = null;
      await loadConversations();
    } on AiApiException catch (e) {
      _error = e.message;
      _lastFailedMessage = trimmed;
    } catch (_) {
      _error = 'Không gửi được tin nhắn. Kiểm tra mạng hoặc backend.';
      _lastFailedMessage = trimmed;
    } finally {
      _sending = false;
      notifyListeners();
    }
  }

  /// Gửi lại tin nhắn thất bại gần nhất. Gỡ bubble user của lần gửi hỏng
  /// trước đó để không hiển thị trùng câu hỏi hai lần.
  Future<void> retryLastMessage() async {
    final text = _lastFailedMessage;
    if (text == null || _sending) return;
    if (_messages.isNotEmpty &&
        _messages.last.isUser &&
        _messages.last.content == text) {
      _messages.removeLast();
    }
    _lastFailedMessage = null;
    _error = null;
    await sendMessage(text);
  }

  Future<bool> deleteConversation(String id) async {
    try {
      await _api.deleteConversation(id);
      _conversations.removeWhere((c) => c.id == id);
      if (_conversationId == id) {
        startNewConversation();
      }
      notifyListeners();
      return true;
    } on AiApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }
}
