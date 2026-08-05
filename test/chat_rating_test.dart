import 'package:flutter_test/flutter_test.dart';
import 'package:labedu/core/api/ai_api_service.dart';
import 'package:labedu/domain/models/ai_chat_models.dart';
import 'package:labedu/presentation/ai_chat/providers/chat_provider.dart';

/// Fake API ghi lại các lời gọi rateMessage, có thể giả lập lỗi mạng.
class _FakeAiApi extends AiApiService {
  final List<(String, int)> ratedCalls = [];
  bool failNextRate = false;

  @override
  Future<void> rateMessage(String messageId, int rating) async {
    if (failNextRate) {
      failNextRate = false;
      throw AiApiException('mất mạng');
    }
    ratedCalls.add((messageId, rating));
  }
}

void main() {
  group('ChatProvider.rateMessage', () {
    late _FakeAiApi api;
    late ChatProvider provider;
    late ChatMessage aiMessage;

    setUp(() {
      api = _FakeAiApi();
      provider = ChatProvider(api: api);
      aiMessage = ChatMessage(
        id: 'local-ai-1',
        serverId: 'server-msg-1',
        role: ChatMessageRole.assistant,
        content: 'H₂O là nước.',
      );
      // ignore: invalid_use_of_protected_member
      provider.messagesForTest.add(aiMessage);
    });

    test('👎 lần đầu: rating -1 được lưu và gửi lên server', () async {
      await provider.rateMessage(aiMessage, -1);

      expect(provider.messages.single.rating, -1);
      expect(api.ratedCalls, [('server-msg-1', -1)]);
    });

    test('bấm lại cùng nút: bỏ chấm (rating về 0)', () async {
      await provider.rateMessage(aiMessage, -1);
      await provider.rateMessage(provider.messages.single, -1);

      expect(provider.messages.single.rating, 0);
      expect(api.ratedCalls.last, ('server-msg-1', 0));
    });

    test('đổi từ 👎 sang 👍: rating chuyển 1', () async {
      await provider.rateMessage(aiMessage, -1);
      await provider.rateMessage(provider.messages.single, 1);

      expect(provider.messages.single.rating, 1);
      expect(api.ratedCalls.last, ('server-msg-1', 1));
    });

    test('lỗi mạng: hoàn tác về rating cũ (optimistic revert)', () async {
      api.failNextRate = true;

      await provider.rateMessage(aiMessage, 1);

      expect(provider.messages.single.rating, 0,
          reason: 'gửi thất bại thì trạng thái phải quay về như cũ');
      expect(api.ratedCalls, isEmpty);
    });

    test('message chưa có serverId (gửi thất bại): không gọi API', () async {
      final localOnly = ChatMessage(
        id: 'local-ai-2',
        role: ChatMessageRole.assistant,
        content: 'chưa đồng bộ',
      );
      // ignore: invalid_use_of_protected_member
      provider.messagesForTest.add(localOnly);

      await provider.rateMessage(localOnly, 1);

      expect(api.ratedCalls, isEmpty);
      expect(localOnly.canRate, isFalse);
    });
  });
}
