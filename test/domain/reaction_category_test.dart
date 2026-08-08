import 'package:flutter_test/flutter_test.dart';
import 'package:labedu/domain/models/reaction_experiment/reaction_category.dart';

void main() {
  group('ReactionCategory – storageKey', () {
    test('storageKey trùng với tên enum', () {
      expect(ReactionCategory.metal.storageKey, 'metal');
      expect(ReactionCategory.acid.storageKey, 'acid');
      expect(ReactionCategory.base.storageKey, 'base');
      expect(ReactionCategory.salt.storageKey, 'salt');
    });

    test('tất cả 4 category đều có storageKey', () {
      for (final c in ReactionCategory.values) {
        expect(c.storageKey, isNotEmpty);
      }
    });
  });

  group('ReactionCategory.fromKey', () {
    test('key hợp lệ trả về đúng enum', () {
      expect(ReactionCategory.fromKey('metal'), ReactionCategory.metal);
      expect(ReactionCategory.fromKey('acid'), ReactionCategory.acid);
      expect(ReactionCategory.fromKey('base'), ReactionCategory.base);
      expect(ReactionCategory.fromKey('salt'), ReactionCategory.salt);
    });

    test('null key → null', () {
      expect(ReactionCategory.fromKey(null), isNull);
    });

    test('string rỗng → null', () {
      expect(ReactionCategory.fromKey(''), isNull);
    });

    test('key không khớp → null', () {
      expect(ReactionCategory.fromKey('unknown'), isNull);
      expect(ReactionCategory.fromKey('METAL'), isNull);  // case-sensitive
      expect(ReactionCategory.fromKey('Metal'), isNull);
    });

    test('round-trip: storageKey → fromKey → storageKey', () {
      for (final c in ReactionCategory.values) {
        final restored = ReactionCategory.fromKey(c.storageKey);
        expect(restored, c);
      }
    });
  });
}
