import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/periodic_elements.dart';

/// ====== Dữ liệu cache cho chế độ Ôn thẻ (offline-first) ======
///
/// Chất và phản ứng được cache về local mỗi khi tải thành công từ backend,
/// nên học sinh ôn được cả khi không có mạng. Trạng thái thuộc/chưa thuộc
/// (Leitner) cũng lưu local theo email.

class CachedSubstance {
  final String id;
  final String formula;
  final String vietnameseName;
  final String? englishName;
  final String? chemicalGroup;
  final String? state;
  final double? molarMass;

  const CachedSubstance({
    required this.id,
    required this.formula,
    required this.vietnameseName,
    this.englishName,
    this.chemicalGroup,
    this.state,
    this.molarMass,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'formula': formula,
        'vietnameseName': vietnameseName,
        'englishName': englishName,
        'chemicalGroup': chemicalGroup,
        'state': state,
        'molarMass': molarMass,
      };

  factory CachedSubstance.fromJson(Map<String, dynamic> json) {
    return CachedSubstance(
      id: json['id'] as String? ?? '',
      formula: json['formula'] as String? ?? '',
      vietnameseName: json['vietnameseName'] as String? ?? '',
      englishName: json['englishName'] as String?,
      chemicalGroup: json['chemicalGroup'] as String?,
      state: json['state'] as String?,
      molarMass: (json['molarMass'] as num?)?.toDouble(),
    );
  }
}

class CachedReaction {
  final String code;
  final String name;
  final String equation;
  final String? reactionType;

  const CachedReaction({
    required this.code,
    required this.name,
    required this.equation,
    this.reactionType,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'equation': equation,
        'reactionType': reactionType,
      };

  factory CachedReaction.fromJson(Map<String, dynamic> json) {
    return CachedReaction(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      equation: json['equation'] as String? ?? '',
      reactionType: json['reactionType'] as String?,
    );
  }
}

/// ====== Thẻ ôn ======

enum ReviewCardType { formulaToName, nameToFormula, reaction }

class ReviewCard {
  final String key;
  final ReviewCardType type;
  final String front;
  final String frontHint;
  final List<String> backLines;

  const ReviewCard({
    required this.key,
    required this.type,
    required this.front,
    required this.frontHint,
    required this.backLines,
  });
}

/// Trạng thái Leitner của một thẻ.
class CardMastery {
  /// 0 = chưa thuộc; mỗi lần "Đã thuộc" +1 (tối đa 3).
  final int level;

  /// Ngày ôn gần nhất (epoch day) — để tính lịch gặp lại.
  final int lastEpochDay;

  const CardMastery({required this.level, required this.lastEpochDay});
}

class FlashcardReviewService {
  FlashcardReviewService._();

  /// Khoảng cách gặp lại theo level (ngày): chưa thuộc gặp ngay,
  /// thuộc 1 lần → 3 ngày, 2 lần → 7 ngày, từ 3 lần → 21 ngày.
  static const List<int> intervals = [0, 3, 7, 21];

  static int epochDay(DateTime time) =>
      time.toUtc().millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;

  // ---------------------------------------------------------------------------
  // Hiển thị công thức: chỉ số sau ký hiệu nguyên tố / ngoặc đóng chuyển thành
  // chỉ số dưới Unicode (H2SO4 → H₂SO₄), hệ số đầu chất giữ nguyên (2KMnO4).
  // ---------------------------------------------------------------------------

  static const _subscripts = {
    '0': '₀', '1': '₁', '2': '₂', '3': '₃', '4': '₄',
    '5': '₅', '6': '₆', '7': '₇', '8': '₈', '9': '₉',
  };

  static String prettyFormula(String raw) {
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final ch = raw[i];
      final isDigit = ch.codeUnitAt(0) >= 0x30 && ch.codeUnitAt(0) <= 0x39;
      if (isDigit && i > 0) {
        final prev = raw[i - 1];
        final prevIsLetter = RegExp(r'[A-Za-z)]').hasMatch(prev);
        final prevIsSubscript = _subscripts.values.contains(
          buffer.isEmpty ? '' : buffer.toString()[buffer.length - 1],
        );
        if (prevIsLetter || prevIsSubscript) {
          buffer.write(_subscripts[ch]);
          continue;
        }
      }
      buffer.write(ch);
    }
    return buffer.toString();
  }

  /// "2KMnO4 -> K2MnO4 + MnO2 + O2" → "2KMnO₄ → K₂MnO₄ + MnO₂ + O₂"
  static String prettyEquation(String raw) {
    return raw
        .split(RegExp(r'\s*->\s*'))
        .map((side) => side
            .split(RegExp(r'\s*\+\s*'))
            .map((part) => prettyFormula(part.trim()))
            .join(' + '))
        .join(' → ');
  }

  // ---------------------------------------------------------------------------
  // Dựng bộ thẻ
  // ---------------------------------------------------------------------------

  /// Tạo toàn bộ thẻ ôn từ chất đã mở khoá + phản ứng có sẵn.
  ///
  /// Mỗi chất sinh 2 thẻ (2 chiều hỏi); chất là NGUYÊN TỐ đơn chất được ghép
  /// thêm dữ liệu bảng tuần hoàn local (số hiệu, chu kỳ, cấu hình electron).
  /// Mỗi phản ứng sinh 1 thẻ dạng "chất tham gia → ?".
  static List<ReviewCard> buildDeck({
    required List<CachedSubstance> substances,
    required List<CachedReaction> reactions,
  }) {
    final cards = <ReviewCard>[];

    for (final s in substances) {
      if (s.formula.isEmpty || s.vietnameseName.isEmpty) continue;

      final pretty = prettyFormula(s.formula);
      final info = <String>[
        if (s.englishName != null && s.englishName!.isNotEmpty) s.englishName!,
        [
          if (s.chemicalGroup != null && s.chemicalGroup!.isNotEmpty)
            s.chemicalGroup!,
          if (s.state != null && s.state!.isNotEmpty) s.state!,
          if (s.molarMass != null) 'M = ${_trimNumber(s.molarMass!)}',
        ].join(' · '),
      ].where((line) => line.isNotEmpty).toList();

      // Nguyên tố đơn chất → ghép dữ liệu bảng tuần hoàn (offline sẵn).
      final element = _elementFor(s.formula);
      final elementLines = element == null
          ? const <String>[]
          : [
              'Số hiệu ${element.number} · Chu kỳ ${element.period}'
                  '${element.group != null ? ' · Nhóm ${element.group}' : ''}',
              'Cấu hình e: ${element.electronConfig}',
              if (element.electronegativity != null)
                'Độ âm điện: ${element.electronegativity}',
            ];

      cards.add(ReviewCard(
        key: 'sub:${s.id}:fn',
        type: ReviewCardType.formulaToName,
        front: pretty,
        frontHint: 'Chất này tên là gì?',
        backLines: [s.vietnameseName, ...info, ...elementLines],
      ));

      cards.add(ReviewCard(
        key: 'sub:${s.id}:nf',
        type: ReviewCardType.nameToFormula,
        front: s.vietnameseName,
        frontHint: 'Công thức hóa học?',
        backLines: [pretty, ...info],
      ));
    }

    for (final r in reactions) {
      if (r.equation.isEmpty) continue;
      final parts = r.equation.split(RegExp(r'\s*->\s*'));
      if (parts.length != 2) continue;

      final reactants = parts[0]
          .split(RegExp(r'\s*\+\s*'))
          .map((p) => prettyFormula(p.trim()))
          .join(' + ');

      cards.add(ReviewCard(
        key: 'rx:${r.code}',
        type: ReviewCardType.reaction,
        front: '$reactants → ?',
        frontHint: 'Sản phẩm là gì?',
        backLines: [
          prettyEquation(r.equation),
          r.name,
          if (r.reactionType != null && r.reactionType!.isNotEmpty)
            _reactionTypeVi(r.reactionType!),
        ],
      ));
    }

    return cards;
  }

  static PeriodicElement? _elementFor(String formula) {
    for (final e in periodicElements) {
      if (e.symbol == formula) return e;
    }
    return null;
  }

  static String _trimNumber(double v) {
    return v == v.truncateToDouble()
        ? v.toInt().toString()
        : v.toStringAsFixed(1);
  }

  static String _reactionTypeVi(String type) => switch (type) {
        'THERMAL_DECOMPOSITION' => 'Phản ứng nhiệt phân',
        'METAL_ACID' => 'Kim loại + axit',
        'PRECIPITATION' => 'Phản ứng kết tủa',
        'NO_REACTION' => 'Không phản ứng',
        'COMBUSTION' => 'Phản ứng cháy',
        'SYNTHESIS' => 'Phản ứng hóa hợp',
        'DISPLACEMENT' => 'Phản ứng thế',
        _ => type,
      };

  // ---------------------------------------------------------------------------
  // Leitner: thẻ nào đến hạn ôn hôm nay?
  // ---------------------------------------------------------------------------

  static bool isDue(CardMastery? mastery, DateTime now) {
    if (mastery == null || mastery.level <= 0) return true;
    final level = mastery.level.clamp(0, intervals.length - 1);
    return epochDay(now) - mastery.lastEpochDay >= intervals[level];
  }

  static List<ReviewCard> dueCards(
    List<ReviewCard> deck,
    Map<String, CardMastery> mastery, {
    required DateTime now,
  }) {
    return deck.where((c) => isDue(mastery[c.key], now)).toList();
  }

  /// Ghi kết quả một lượt lật: thuộc → level +1 (tối đa 3), chưa thuộc → về 0.
  static Map<String, CardMastery> markResult(
    Map<String, CardMastery> mastery,
    String cardKey, {
    required bool known,
    required DateTime now,
  }) {
    final current = mastery[cardKey]?.level ?? 0;
    final next = known ? (current + 1).clamp(0, intervals.length - 1) : 0;
    return {
      ...mastery,
      cardKey: CardMastery(level: next, lastEpochDay: epochDay(now)),
    };
  }

  // ---------------------------------------------------------------------------
  // Lưu trữ local theo email
  // ---------------------------------------------------------------------------

  static String _subsKey(String email) => 'review_substances_$email';
  static String _rxKey(String email) => 'review_reactions_$email';
  static String _masteryKey(String email) => 'review_mastery_$email';

  static Future<void> saveSubstances(
      String email, List<CachedSubstance> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _subsKey(email), jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  static Future<List<CachedSubstance>> loadSubstances(String email) async {
    final prefs = await SharedPreferences.getInstance();
    return _decodeList(prefs.getString(_subsKey(email)))
        .map(CachedSubstance.fromJson)
        .toList();
  }

  static Future<void> saveReactions(
      String email, List<CachedReaction> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _rxKey(email), jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  static Future<List<CachedReaction>> loadReactions(String email) async {
    final prefs = await SharedPreferences.getInstance();
    return _decodeList(prefs.getString(_rxKey(email)))
        .map(CachedReaction.fromJson)
        .toList();
  }

  static Future<Map<String, CardMastery>> loadMastery(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_masteryKey(email));
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return {};
    return decoded.map((key, value) {
      final list = (value as List).cast<num>();
      return MapEntry(
        key,
        CardMastery(level: list[0].toInt(), lastEpochDay: list[1].toInt()),
      );
    });
  }

  static Future<void> saveMastery(
      String email, Map<String, CardMastery> mastery) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _masteryKey(email),
      jsonEncode(mastery
          .map((key, m) => MapEntry(key, [m.level, m.lastEpochDay]))),
    );
  }

  static List<Map<String, dynamic>> _decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded.whereType<Map<String, dynamic>>().toList();
  }
}
