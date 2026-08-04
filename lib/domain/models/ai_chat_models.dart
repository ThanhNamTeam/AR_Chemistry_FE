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
    this.serverId,
    this.rating = 0,
  });

  final String id;
  final ChatMessageRole role;
  final String content;
  final DateTime? createdAt;
  final String? modelUsed;
  final bool reusedMemory;
  final double? similarityScore;

  /// Id message trên backend — cần để gọi API đánh giá 👍/👎.
  /// Null khi message chưa đồng bộ với server (ví dụ gửi thất bại).
  final String? serverId;

  /// 1 = 👍, -1 = 👎, 0 = chưa chấm.
  final int rating;

  bool get isUser => role == ChatMessageRole.user;
  bool get canRate => !isUser && serverId != null && serverId!.isNotEmpty;

  ChatMessage copyWith({int? rating}) {
    return ChatMessage(
      id: id,
      role: role,
      content: content,
      createdAt: createdAt,
      modelUsed: modelUsed,
      reusedMemory: reusedMemory,
      similarityScore: similarityScore,
      serverId: serverId,
      rating: rating ?? this.rating,
    );
  }
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
    this.messageId,
  });

  final String conversationId;
  final String answer;
  final String? modelUsed;
  final bool reusedMemory;
  final double? similarityScore;
  final DateTime? timestamp;

  /// Id ASSISTANT message trên backend — dùng cho đánh giá 👍/👎.
  final String? messageId;

  factory AiChatResult.fromJson(Map<String, dynamic> json) {
    return AiChatResult(
      conversationId: json['conversationId'] as String,
      answer: json['answer'] as String? ?? '',
      modelUsed: json['modelUsed'] as String?,
      reusedMemory: json['reusedMemory'] as bool? ?? false,
      similarityScore: (json['similarityScore'] as num?)?.toDouble(),
      timestamp: _parseInstant(json['timestamp']),
      messageId: json['messageId'] as String?,
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
    final id = m['id'] as String? ?? '';
    return ChatMessage(
      id: id,
      serverId: id.isEmpty ? null : id,
      role: _roleFromString(m['role'] as String?),
      content: m['content'] as String? ?? '',
      createdAt: _parseInstant(m['createdAt']),
      modelUsed: m['modelUsed'] as String?,
      rating: (m['rating'] as num?)?.toInt() ?? 0,
    );
  }).toList();
}
