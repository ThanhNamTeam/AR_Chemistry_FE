import 'package:flutter_test/flutter_test.dart';
import 'package:labedu/core/services/flashcard_review_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('prettyFormula', () {
    test('chỉ số sau nguyên tố thành subscript, hệ số đầu giữ nguyên', () {
      expect(FlashcardReviewService.prettyFormula('H2SO4'), 'H₂SO₄');
      expect(FlashcardReviewService.prettyFormula('2KMnO4'), '2KMnO₄');
      expect(FlashcardReviewService.prettyFormula('Ca(OH)2'), 'Ca(OH)₂');
      expect(FlashcardReviewService.prettyFormula('Fe'), 'Fe');
    });

    test('phương trình: mũi tên và từng vế được format', () {
      expect(
        FlashcardReviewService.prettyEquation(
            '2KMnO4 -> K2MnO4 + MnO2 + O2'),
        '2KMnO₄ → K₂MnO₄ + MnO₂ + O₂',
      );
    });
  });

  group('buildDeck', () {
    // Phản ứng lấy đúng theo seed hiện có của backend.
    const reactions = [
      CachedReaction(
        code: 'KMNO4_THERMAL_DECOMPOSITION',
        name: 'Nhiệt phân kali pemanganat',
        equation: '2KMnO4 -> K2MnO4 + MnO2 + O2',
        reactionType: 'THERMAL_DECOMPOSITION',
      ),
      CachedReaction(
        code: 'ZN_HCL',
        name: 'Kẽm tác dụng axit clohiđric',
        equation: 'Zn + 2HCl -> ZnCl2 + H2',
        reactionType: 'METAL_ACID',
      ),
    ];

    const substances = [
      CachedSubstance(
        id: 's1',
        formula: 'H2SO4',
        vietnameseName: 'Axit sunfuric',
        englishName: 'Sulfuric acid',
        chemicalGroup: 'ACID',
        state: 'LIQUID',
      ),
      CachedSubstance(
        id: 's2',
        formula: 'Fe',
        vietnameseName: 'Sắt',
        englishName: 'Iron',
      ),
    ];

    test('mỗi chất sinh 2 thẻ (2 chiều), mỗi phản ứng sinh 1 thẻ', () {
      final deck = FlashcardReviewService.buildDeck(
        substances: substances,
        reactions: reactions,
      );

      expect(deck.length, 2 * 2 + 2);
      expect(deck.where((c) => c.type == ReviewCardType.formulaToName), hasLength(2));
      expect(deck.where((c) => c.type == ReviewCardType.nameToFormula), hasLength(2));
      expect(deck.where((c) => c.type == ReviewCardType.reaction), hasLength(2));
    });

    test('thẻ phản ứng: mặt trước GIẤU sản phẩm, mặt sau có đủ phương trình', () {
      final deck = FlashcardReviewService.buildDeck(
        substances: const [],
        reactions: reactions,
      );

      final zn = deck.firstWhere((c) => c.key == 'rx:ZN_HCL');
      expect(zn.front, 'Zn + 2HCl → ?');
      expect(zn.front.contains('ZnCl'), isFalse,
          reason: 'mặt trước không được lộ sản phẩm');
      expect(zn.backLines.first, 'Zn + 2HCl → ZnCl₂ + H₂');
      expect(zn.backLines, contains('Kẽm tác dụng axit clohiđric'));
      expect(zn.backLines, contains('Kim loại + axit'));
    });

    test('nguyên tố đơn chất được ghép dữ liệu bảng tuần hoàn local', () {
      final deck = FlashcardReviewService.buildDeck(
        substances: substances,
        reactions: const [],
      );

      final fe = deck.firstWhere((c) => c.key == 'sub:s2:fn');
      expect(fe.backLines.join(' '), contains('Số hiệu 26'));
      expect(fe.backLines.join(' '), contains('[Ar]3d⁶4s²'));
    });

    test('hợp chất KHÔNG bị ghép nhầm dữ liệu nguyên tố', () {
      final deck = FlashcardReviewService.buildDeck(
        substances: substances,
        reactions: const [],
      );

      final acid = deck.firstWhere((c) => c.key == 'sub:s1:fn');
      expect(acid.backLines.join(' '), isNot(contains('Số hiệu')));
    });

    test('phương trình sai định dạng bị bỏ qua, không crash', () {
      final deck = FlashcardReviewService.buildDeck(
        substances: const [],
        reactions: const [
          CachedReaction(code: 'BAD', name: 'x', equation: 'khong co mui ten'),
        ],
      );
      expect(deck, isEmpty);
    });
  });

  group('Leitner scheduling', () {
    final day0 = DateTime.utc(2026, 8, 3);

    test('thẻ chưa từng ôn: đến hạn ngay', () {
      expect(FlashcardReviewService.isDue(null, day0), isTrue);
    });

    test('thuộc 1 lần: nghỉ 3 ngày rồi mới gặp lại', () {
      var mastery = <String, CardMastery>{};
      mastery = FlashcardReviewService.markResult(mastery, 'k',
          known: true, now: day0);

      expect(
        FlashcardReviewService.isDue(
            mastery['k'], day0.add(const Duration(days: 1))),
        isFalse,
        reason: 'ngày +1 chưa đến hạn',
      );
      expect(
        FlashcardReviewService.isDue(
            mastery['k'], day0.add(const Duration(days: 3))),
        isTrue,
        reason: 'ngày +3 đến hạn',
      );
    });

    test('chưa thuộc: reset về level 0, gặp lại ngay lượt sau', () {
      var mastery = <String, CardMastery>{};
      mastery = FlashcardReviewService.markResult(mastery, 'k',
          known: true, now: day0);
      mastery = FlashcardReviewService.markResult(mastery, 'k',
          known: true, now: day0.add(const Duration(days: 3)));
      // Đang level 2 → quên
      mastery = FlashcardReviewService.markResult(mastery, 'k',
          known: false, now: day0.add(const Duration(days: 5)));

      expect(mastery['k']!.level, 0);
      expect(
        FlashcardReviewService.isDue(
            mastery['k'], day0.add(const Duration(days: 5))),
        isTrue,
      );
    });

    test('level tối đa 3: khoảng cách chốt ở 21 ngày', () {
      var mastery = <String, CardMastery>{};
      var lastMark = day0;
      for (var i = 0; i < 6; i++) {
        lastMark = day0.add(Duration(days: 30 * i));
        mastery = FlashcardReviewService.markResult(mastery, 'k',
            known: true, now: lastMark);
      }

      expect(mastery['k']!.level, 3);
      expect(
        FlashcardReviewService.isDue(
            mastery['k'], lastMark.add(const Duration(days: 20))),
        isFalse,
      );
      expect(
        FlashcardReviewService.isDue(
            mastery['k'], lastMark.add(const Duration(days: 21))),
        isTrue,
      );
    });
  });

  group('cache local (offline)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('lưu rồi đọc lại chất + phản ứng + mastery nguyên vẹn', () async {
      const email = 'hs@test.vn';
      const subs = [
        CachedSubstance(id: 's1', formula: 'NaCl', vietnameseName: 'Muối ăn'),
      ];
      const rx = [
        CachedReaction(code: 'R1', name: 'PƯ', equation: 'A -> B'),
      ];

      await FlashcardReviewService.saveSubstances(email, subs);
      await FlashcardReviewService.saveReactions(email, rx);
      var mastery = FlashcardReviewService.markResult({}, 'sub:s1:fn',
          known: true, now: DateTime.utc(2026, 8, 3));
      await FlashcardReviewService.saveMastery(email, mastery);

      final loadedSubs = await FlashcardReviewService.loadSubstances(email);
      final loadedRx = await FlashcardReviewService.loadReactions(email);
      final loadedMastery = await FlashcardReviewService.loadMastery(email);

      expect(loadedSubs.single.formula, 'NaCl');
      expect(loadedSubs.single.vietnameseName, 'Muối ăn');
      expect(loadedRx.single.equation, 'A -> B');
      expect(loadedMastery['sub:s1:fn']!.level, 1);
    });

    test('email khác nhau không nhìn thấy dữ liệu của nhau', () async {
      await FlashcardReviewService.saveSubstances('a@x.vn', const [
        CachedSubstance(id: '1', formula: 'Fe', vietnameseName: 'Sắt'),
      ]);

      final other = await FlashcardReviewService.loadSubstances('b@x.vn');
      expect(other, isEmpty);
    });
  });
}
