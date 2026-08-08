import 'package:flutter_test/flutter_test.dart';
import 'package:labedu/core/models/response/ar_scan_reward_response.dart';
import 'package:labedu/core/models/response/reaction_check_response.dart';

// ─── Helpers ────────────────────────────────────────────────────────────────

Map<String, dynamic> _validJson({Map<String, dynamic> overrides = const {}}) {
  return <String, dynamic>{
    'matched': true,
    'reason': 'REACTION_MATCHED',
    'message': 'ok',
    'reactionCode': 'FE_HCL',
    'affectedQrPayloads': <String>[],
    'affectedFormulas': <String>[],
    'reactants': <Map<String, dynamic>>[
      <String, dynamic>{'formula': 'Fe'},
      <String, dynamic>{'formula': 'HCl'},
    ],
    ...overrides,
  };
}

// ─── Tests ──────────────────────────────────────────────────────────────────

void main() {
  // ── fromJson – thành công ─────────────────────────────────────────────────

  group('ReactionCheckResponse.fromJson – thành công', () {
    test('parse phản ứng khớp (matched=true)', () {
      final result = ReactionCheckResponse.fromJson(_validJson());
      expect(result.matched, isTrue);
      expect(result.reason, 'REACTION_MATCHED');
      expect(result.message, 'ok');
      expect(result.reactionCode, 'FE_HCL');
      expect(result.reactantFormulas, ['Fe', 'HCl']);
    });

    test('parse không khớp (matched=false)', () {
      final result = ReactionCheckResponse.fromJson(_validJson(overrides: {
        'matched': false,
        'reason': 'NO_MATCH',
      }));
      expect(result.matched, isFalse);
      expect(result.reason, 'NO_MATCH');
    });

    test('affectedQrPayloads và affectedFormulas parse đúng', () {
      final result = ReactionCheckResponse.fromJson(_validJson(overrides: {
        'affectedQrPayloads': ['QR1', 'QR2'],
        'affectedFormulas': ['Fe', 'HCl', 'FeCl2'],
      }));
      expect(result.affectedQrPayloads, ['QR1', 'QR2']);
      expect(result.affectedFormulas, ['Fe', 'HCl', 'FeCl2']);
    });

    test('reactants rỗng → reactantFormulas rỗng', () {
      final result = ReactionCheckResponse.fromJson(_validJson(overrides: {
        'reactants': <Map<String, dynamic>>[],
      }));
      expect(result.reactantFormulas, isEmpty);
    });

    test('reactants null → reactantFormulas rỗng', () {
      final result = ReactionCheckResponse.fromJson(_validJson(overrides: {
        'reactants': null,
      }));
      expect(result.reactantFormulas, isEmpty);
    });

    test('reactants với item thiếu "formula" → bị lọc bỏ', () {
      final result = ReactionCheckResponse.fromJson(_validJson(overrides: {
        'reactants': [
          {'formula': 'Fe'},
          {'noFormula': 'xxx'}, // thiếu formula key
        ],
      }));
      expect(result.reactantFormulas, ['Fe']);
    });

    test('reactionCode null → null (optional)', () {
      final result = ReactionCheckResponse.fromJson(_validJson(overrides: {
        'reactionCode': null,
      }));
      expect(result.reactionCode, isNull);
    });

    test('equation được parse khi có', () {
      final result = ReactionCheckResponse.fromJson(_validJson(overrides: {
        'equation': 'Fe + 2HCl → FeCl₂ + H₂↑',
      }));
      expect(result.equation, 'Fe + 2HCl → FeCl₂ + H₂↑');
    });

    test('equation null → null', () {
      final result = ReactionCheckResponse.fromJson(_validJson());
      expect(result.equation, isNull);
    });
  });

  // ── fromJson – reward ─────────────────────────────────────────────────────

  group('ReactionCheckResponse.fromJson – reward', () {
    test('có reward → arScanReward không null', () {
      final result = ReactionCheckResponse.fromJson(_validJson(overrides: {
        'reward': {
          'rewarded': true,
          'kpEarned': 10,
          'todayRewardedCount': 1,
          'dailyLimit': 5,
          'currentBalance': 100,
          'message': 'Earned 10 KP!',
        },
      }));
      expect(result.arScanReward, isNotNull);
      expect(result.arScanReward!.rewarded, isTrue);
      expect(result.arScanReward!.kpEarned, 10);
    });

    test('không có reward → arScanReward null', () {
      final result = ReactionCheckResponse.fromJson(_validJson());
      expect(result.arScanReward, isNull);
    });
  });

  // ── fromJson – lỗi ───────────────────────────────────────────────────────

  group('ReactionCheckResponse.fromJson – lỗi format', () {
    test('thiếu "matched" → FormatException', () {
      expect(
        () => ReactionCheckResponse.fromJson(<String, dynamic>{
          'reason': 'X',
          'message': 'Y',
        }),
        throwsFormatException,
      );
    });

    test('"matched" sai kiểu (String) → FormatException', () {
      expect(
        () => ReactionCheckResponse.fromJson(<String, dynamic>{
          'matched': 'yes',
          'reason': 'X',
          'message': 'Y',
        }),
        throwsFormatException,
      );
    });

    test('"reason" null → FormatException', () {
      expect(
        () => ReactionCheckResponse.fromJson(<String, dynamic>{
          'matched': true,
          'reason': null,
          'message': 'Y',
        }),
        throwsFormatException,
      );
    });

    test('"message" null → FormatException', () {
      expect(
        () => ReactionCheckResponse.fromJson(<String, dynamic>{
          'matched': true,
          'reason': 'R',
          'message': null,
        }),
        throwsFormatException,
      );
    });

    test('json rỗng → FormatException', () {
      expect(
        () => ReactionCheckResponse.fromJson(<String, dynamic>{}),
        throwsFormatException,
      );
    });
  });

  // ── toBridgeJson ──────────────────────────────────────────────────────────

  group('ReactionCheckResponse.toBridgeJson()', () {
    test('các field bắt buộc luôn có mặt', () {
      final response = ReactionCheckResponse.fromJson(_validJson());
      final bridge = response.toBridgeJson();
      expect(bridge.containsKey('matched'), isTrue);
      expect(bridge.containsKey('reason'), isTrue);
      expect(bridge.containsKey('message'), isTrue);
      expect(bridge.containsKey('affectedQrPayloads'), isTrue);
      expect(bridge.containsKey('affectedFormulas'), isTrue);
      expect(bridge.containsKey('reactantFormulas'), isTrue);
    });

    test('reactionCode optional: có khi set, thiếu khi null', () {
      final withCode = ReactionCheckResponse.fromJson(
          _validJson(overrides: {'reactionCode': 'ZN_HCL'}));
      expect(withCode.toBridgeJson().containsKey('reactionCode'), isTrue);
      expect(withCode.toBridgeJson()['reactionCode'], 'ZN_HCL');

      final withoutCode = ReactionCheckResponse.fromJson(
          _validJson(overrides: {'reactionCode': null}));
      expect(withoutCode.toBridgeJson().containsKey('reactionCode'), isFalse);
    });

    test('matched=false round-trip qua bridge', () {
      final response = ReactionCheckResponse.fromJson(
          _validJson(overrides: {'matched': false, 'reason': 'NO_MATCH'}));
      final bridge = response.toBridgeJson();
      expect(bridge['matched'], isFalse);
      expect(bridge['reason'], 'NO_MATCH');
    });
  });

  // ── ArScanRewardResponse ──────────────────────────────────────────────────

  group('ArScanRewardResponse.fromJson / toBridgeJson', () {
    const rewardJson = <String, dynamic>{
      'rewarded': true,
      'kpEarned': 20,
      'todayRewardedCount': 2,
      'dailyLimit': 5,
      'currentBalance': 200,
      'message': 'Great scan!',
    };

    test('parse đầy đủ', () {
      final r = ArScanRewardResponse.fromJson(rewardJson);
      expect(r.rewarded, isTrue);
      expect(r.kpEarned, 20);
      expect(r.todayRewardedCount, 2);
      expect(r.dailyLimit, 5);
      expect(r.currentBalance, 200);
      expect(r.message, 'Great scan!');
    });

    test('json rỗng → default không crash', () {
      final r = ArScanRewardResponse.fromJson({});
      expect(r.rewarded, isFalse);
      expect(r.kpEarned, 0);
      expect(r.dailyLimit, 5);
    });

    test('toBridgeJson round-trip', () {
      final r = ArScanRewardResponse.fromJson(rewardJson);
      final bridge = r.toBridgeJson();
      expect(bridge['rewarded'], isTrue);
      expect(bridge['kpEarned'], 20);
      expect(bridge['message'], 'Great scan!');
    });
  });
}
