enum ChatMessageRole { user, assistant, system }

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.createdAt,
    this.modelUsed,
    this.reusedMemory = false,
    this.similarityScore,
  });

  final String id;
  final ChatMessageRole role;
  final String content;
  final DateTime? createdAt;
  final String? modelUsed;
  final bool reusedMemory;
  final double? similarityScore;

  bool get isUser => role == ChatMessageRole.user;
}

class ConversationSummary {
  ConversationSummary({
    required this.id,
    required this.title,
    this.modelUsed,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String? modelUsed;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ConversationSummary.fromJson(Map<String, dynamic> json) {
    return ConversationSummary(
      id: json['id'] as String,
      title: (json['title'] as String?) ?? 'Cuộc trò chuyện',
      modelUsed: json['modelUsed'] as String?,
      createdAt: _parseInstant(json['createdAt']),
      updatedAt: _parseInstant(json['updatedAt']),
    );
  }
}

class AiChatResult {
  AiChatResult({
    required this.conversationId,
    required this.answer,
    this.modelUsed,
    this.reusedMemory = false,
    this.similarityScore,
    this.timestamp,
  });

  final String conversationId;
  final String answer;
  final String? modelUsed;
  final bool reusedMemory;
  final double? similarityScore;
  final DateTime? timestamp;

  factory AiChatResult.fromJson(Map<String, dynamic> json) {
    return AiChatResult(
      conversationId: json['conversationId'] as String,
      answer: json['answer'] as String? ?? '',
      modelUsed: json['modelUsed'] as String?,
      reusedMemory: json['reusedMemory'] as bool? ?? false,
      similarityScore: (json['similarityScore'] as num?)?.toDouble(),
      timestamp: _parseInstant(json['timestamp']),
    );
  }
}

DateTime? _parseInstant(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

ChatMessageRole _roleFromString(String? role) {
  switch (role?.toUpperCase()) {
    case 'USER':
      return ChatMessageRole.user;
    case 'ASSISTANT':
      return ChatMessageRole.assistant;
    case 'SYSTEM':
      return ChatMessageRole.system;
    default:
      return ChatMessageRole.assistant;
  }
}

List<ChatMessage> messagesFromConversationDetail(Map<String, dynamic> json) {
  final raw = json['messages'];
  if (raw is! List) return [];
  return raw.map((item) {
    final m = item as Map<String, dynamic>;
    return ChatMessage(
      id: m['id'] as String? ?? '',
      role: _roleFromString(m['role'] as String?),
      content: m['content'] as String? ?? '',
      createdAt: _parseInstant(m['createdAt']),
      modelUsed: m['modelUsed'] as String?,
    );
  }).toList();
}
