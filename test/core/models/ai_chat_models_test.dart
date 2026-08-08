import 'package:flutter_test/flutter_test.dart';

import 'package:labedu/domain/models/ai_chat_models.dart';

void main() {
  // ─── ChatMessage ─────────────────────────────────────────────────────────
  group('ChatMessage', () {
    test('isUser is true for user role', () {
      final msg = ChatMessage(
        id: '1',
        role: ChatMessageRole.user,
        content: 'Hello',
      );
      expect(msg.isUser, true);
    });

    test('isUser is false for assistant role', () {
      final msg = ChatMessage(
        id: '2',
        role: ChatMessageRole.assistant,
        content: 'Hi',
      );
      expect(msg.isUser, false);
    });

    test('canRate is true when assistant has serverId', () {
      final msg = ChatMessage(
        id: '3',
        role: ChatMessageRole.assistant,
        content: 'Answer',
        serverId: 'srv-001',
      );
      expect(msg.canRate, true);
    });

    test('canRate is false when user message', () {
      final msg = ChatMessage(
        id: '4',
        role: ChatMessageRole.user,
        content: 'Question',
        serverId: 'srv-001',
      );
      expect(msg.canRate, false);
    });

    test('canRate is false when serverId is null', () {
      final msg = ChatMessage(
        id: '5',
        role: ChatMessageRole.assistant,
        content: 'Answer',
      );
      expect(msg.canRate, false);
    });

    test('canRate is false when serverId is empty', () {
      final msg = ChatMessage(
        id: '6',
        role: ChatMessageRole.assistant,
        content: 'Answer',
        serverId: '',
      );
      expect(msg.canRate, false);
    });

    test('copyWith updates rating', () {
      final msg = ChatMessage(
        id: '7',
        role: ChatMessageRole.assistant,
        content: 'Good answer',
        rating: 0,
      );
      final updated = msg.copyWith(rating: 1);
      expect(updated.rating, 1);
      expect(updated.id, msg.id);
      expect(updated.content, msg.content);
    });

    test('default rating is 0', () {
      final msg = ChatMessage(
        id: '8',
        role: ChatMessageRole.assistant,
        content: 'Answer',
      );
      expect(msg.rating, 0);
      expect(msg.reusedMemory, false);
    });
  });

  // ─── ConversationSummary.fromJson ────────────────────────────────────────
  group('ConversationSummary.fromJson', () {
    test('parses full JSON', () {
      final conv = ConversationSummary.fromJson({
        'id': 'conv-1',
        'title': 'Chemistry questions',
        'modelUsed': 'gpt-4',
        'createdAt': '2024-01-01T10:00:00Z',
        'updatedAt': '2024-01-02T10:00:00Z',
      });
      expect(conv.id, 'conv-1');
      expect(conv.title, 'Chemistry questions');
      expect(conv.modelUsed, 'gpt-4');
      expect(conv.createdAt, isNotNull);
      expect(conv.updatedAt, isNotNull);
    });

    test('defaults title when null', () {
      final conv = ConversationSummary.fromJson({
        'id': 'conv-2',
        'title': null,
      });
      expect(conv.title, 'Cuộc trò chuyện');
    });

    test('handles missing dates', () {
      final conv = ConversationSummary.fromJson({
        'id': 'conv-3',
        'title': 'Test',
      });
      expect(conv.createdAt, isNull);
      expect(conv.updatedAt, isNull);
    });
  });

  // ─── AiChatResult.fromJson ───────────────────────────────────────────────
  group('AiChatResult.fromJson', () {
    test('parses full JSON', () {
      final result = AiChatResult.fromJson({
        'conversationId': 'conv-1',
        'answer': 'H₂O is water',
        'modelUsed': 'gpt-4',
        'reusedMemory': true,
        'similarityScore': 0.95,
        'timestamp': '2024-01-01T10:00:00Z',
        'messageId': 'msg-1',
      });
      expect(result.conversationId, 'conv-1');
      expect(result.answer, 'H₂O is water');
      expect(result.modelUsed, 'gpt-4');
      expect(result.reusedMemory, true);
      expect(result.similarityScore, 0.95);
      expect(result.timestamp, isNotNull);
      expect(result.messageId, 'msg-1');
    });

    test('defaults when optional fields missing', () {
      final result = AiChatResult.fromJson({
        'conversationId': 'conv-2',
        'answer': null,
      });
      expect(result.answer, '');
      expect(result.reusedMemory, false);
      expect(result.similarityScore, isNull);
      expect(result.timestamp, isNull);
      expect(result.messageId, isNull);
    });
  });

  // ─── messagesFromConversationDetail ─────────────────────────────────────
  group('messagesFromConversationDetail', () {
    test('parses list of messages', () {
      final messages = messagesFromConversationDetail({
        'messages': [
          {
            'id': 'm1',
            'role': 'USER',
            'content': 'What is H₂O?',
            'createdAt': '2024-01-01T10:00:00Z',
            'rating': 0,
          },
          {
            'id': 'm2',
            'role': 'ASSISTANT',
            'content': 'Water',
            'createdAt': '2024-01-01T10:00:01Z',
            'rating': 1,
          },
        ],
      });
      expect(messages.length, 2);
      expect(messages[0].role, ChatMessageRole.user);
      expect(messages[1].role, ChatMessageRole.assistant);
      expect(messages[1].rating, 1);
    });

    test('returns empty list when messages is not a list', () {
      final messages = messagesFromConversationDetail({'messages': null});
      expect(messages, isEmpty);
    });

    test('returns empty list when messages key missing', () {
      final messages = messagesFromConversationDetail({});
      expect(messages, isEmpty);
    });

    test('handles SYSTEM role', () {
      final messages = messagesFromConversationDetail({
        'messages': [
          {'id': 'm1', 'role': 'SYSTEM', 'content': 'Sys msg'},
        ],
      });
      expect(messages[0].role, ChatMessageRole.system);
    });

    test('unknown role defaults to assistant', () {
      final messages = messagesFromConversationDetail({
        'messages': [
          {'id': 'm1', 'role': 'UNKNOWN', 'content': 'msg'},
        ],
      });
      expect(messages[0].role, ChatMessageRole.assistant);
    });

    test('empty id results in null serverId', () {
      final messages = messagesFromConversationDetail({
        'messages': [
          {'id': '', 'role': 'USER', 'content': 'msg'},
        ],
      });
      expect(messages[0].serverId, isNull);
    });
  });
}
