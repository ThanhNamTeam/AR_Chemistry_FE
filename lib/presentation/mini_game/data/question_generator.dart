import 'dart:math';

import '../models/game_models.dart';
import 'chemistry_data.dart';

class QuestionGenerator {
  static final Random _rng = Random();
  static List<ChemQuestion>? _cachedAll;

  static List<ChemQuestion> getAllQuestions() {
    if (_cachedAll != null) return _cachedAll!;
    final q = <ChemQuestion>[];

    final massElements = ChemistryData.elementsWithAtomicMass;
    final valenceElements = ChemistryData.elementsWithValence;
    final allMassStrs = massElements.map((e) => e.atomicMassStr).toSet().toList();
    final allNamesVi = massElements.map((e) => e.nameVi).toList();
    final allSymbols = massElements.map((e) => e.symbol).toList();
    final allValenceStrs = valenceElements.map((e) => e.valenceStr).toSet().toList();

    int idCounter = 0;
    String nextId() => 'q${idCounter++}';

    // ── Types from atomic-mass poem ──────────────────────────────────────
    for (final el in massElements) {
      final mass = el.atomicMassStr;
      final name = el.nameVi;
      final sym = el.symbol;
      final poem = el.atomicMassPoemLine;
      final exp = el.explanation;

      // Type A – Missing atomic mass in poem
      q.add(ChemQuestion(
        id: nextId(),
        type: QuestionType.a,
        questionText: '${name} số ___ ${_poemSuffix(poem)}',
        choices: _shuffle4(mass, _distractors(allMassStrs, mass, 3)),
        correctAnswer: mass,
        elementSymbol: sym,
        poemLine: poem,
        explanation: exp,
      ));

      // Type B – Missing element name in poem
      q.add(ChemQuestion(
        id: nextId(),
        type: QuestionType.b,
        questionText: '___ số $mass ${_poemSuffix(poem)}',
        choices: _shuffle4(name, _distractors(allNamesVi, name, 3)),
        correctAnswer: name,
        elementSymbol: sym,
        poemLine: poem,
        explanation: exp,
      ));

      // Type C – Symbol recognition
      q.add(ChemQuestion(
        id: nextId(),
        type: QuestionType.c,
        questionText: 'Ký hiệu hóa học của $name là gì?',
        choices: _shuffle4(sym, _distractors(allSymbols, sym, 3)),
        correctAnswer: sym,
        elementSymbol: sym,
        poemLine: poem,
        explanation: exp,
      ));

      // Type D – Atomic mass recognition
      q.add(ChemQuestion(
        id: nextId(),
        type: QuestionType.d,
        questionText: 'Khối lượng nguyên tử của $name ($sym) là bao nhiêu?',
        choices: _shuffle4(mass, _distractors(allMassStrs, mass, 3)),
        correctAnswer: mass,
        elementSymbol: sym,
        poemLine: poem,
        explanation: exp,
      ));

      // Type G – Complete the poem (blank replaces the number)
      q.add(ChemQuestion(
        id: nextId(),
        type: QuestionType.g,
        questionText: '$name ___ ${_poemSuffix(poem)}',
        choices: _shuffle4(mass, _distractors(allMassStrs, mass, 3)),
        correctAnswer: mass,
        elementSymbol: sym,
        poemLine: poem,
        explanation: exp,
      ));

      // Type H – True (atomic mass correct)
      q.add(ChemQuestion(
        id: nextId(),
        type: QuestionType.h,
        questionText: '$name ($sym) có khối lượng nguyên tử là $mass đvC.',
        choices: const ['Đúng', 'Sai'],
        correctAnswer: 'Đúng',
        elementSymbol: sym,
        poemLine: poem,
        explanation: exp,
      ));

      // Type H – False (atomic mass wrong – use a neighbor mass)
      final falseMass = _pickOne(allMassStrs, mass);
      q.add(ChemQuestion(
        id: nextId(),
        type: QuestionType.h,
        questionText: '$name ($sym) có khối lượng nguyên tử là $falseMass đvC.',
        choices: const ['Đúng', 'Sai'],
        correctAnswer: 'Sai',
        elementSymbol: sym,
        poemLine: poem,
        explanation: 'Sai. Khối lượng nguyên tử của $name là $mass đvC, không phải $falseMass.',
      ));

      // Type I – Match element symbol to atomic mass
      q.add(ChemQuestion(
        id: nextId(),
        type: QuestionType.i,
        questionText: '$sym → ?  (Khối lượng nguyên tử)',
        choices: _shuffle4(mass, _distractors(allMassStrs, mass, 3)),
        correctAnswer: mass,
        elementSymbol: sym,
        poemLine: poem,
        explanation: exp,
      ));
    }

    // ── Types from valence poem ──────────────────────────────────────────
    for (final el in valenceElements) {
      final name = el.nameVi;
      final sym = el.symbol;
      final poem = el.valencePoemLine;
      final exp = el.explanation;
      final valStr = el.valenceStr;

      if (el.hasMultipleValences) {
        // Type F – Multiple valence recognition
        q.add(ChemQuestion(
          id: nextId(),
          type: QuestionType.f,
          questionText: 'Hóa trị thường gặp của $name ($sym) là gì?',
          choices: _shuffle4(valStr, _distractors(allValenceStrs, valStr, 3)),
          correctAnswer: valStr,
          elementSymbol: sym,
          poemLine: poem,
          explanation: exp,
        ));
      } else {
        // Type E – Single valence recognition
        q.add(ChemQuestion(
          id: nextId(),
          type: QuestionType.e,
          questionText: 'Hóa trị của $name ($sym) là bao nhiêu?',
          choices: _shuffle4(valStr, _distractors(allValenceStrs, valStr, 3)),
          correctAnswer: valStr,
          elementSymbol: sym,
          poemLine: poem,
          explanation: exp,
        ));
      }

      // Type J – Match symbol to valence
      q.add(ChemQuestion(
        id: nextId(),
        type: QuestionType.j,
        questionText: '$sym → ?  (Hóa trị)',
        choices: _shuffle4(valStr, _distractors(allValenceStrs, valStr, 3)),
        correctAnswer: valStr,
        elementSymbol: sym,
        poemLine: poem,
        explanation: exp,
      ));

      // Type H – True/False for valence
      q.add(ChemQuestion(
        id: nextId(),
        type: QuestionType.h,
        questionText: '$name ($sym) có hóa trị là $valStr.',
        choices: const ['Đúng', 'Sai'],
        correctAnswer: 'Đúng',
        elementSymbol: sym,
        poemLine: poem,
        explanation: exp,
      ));

      final falseVal = _pickOne(allValenceStrs, valStr);
      q.add(ChemQuestion(
        id: nextId(),
        type: QuestionType.h,
        questionText: '$name ($sym) có hóa trị là $falseVal.',
        choices: const ['Đúng', 'Sai'],
        correctAnswer: 'Sai',
        elementSymbol: sym,
        poemLine: poem,
        explanation: 'Sai. Hóa trị của $name là $valStr, không phải $falseVal.',
      ));
    }

    // ── Type G (valence) – Fill in valence from poem line ─────────────────
    // Generate one question per UNIQUE poem line to avoid duplicates.
    final seenValencePoems = <String>{};
    for (final el in valenceElements) {
      final poem = el.valencePoemLine;
      if (poem.isEmpty || seenValencePoems.contains(poem)) continue;
      seenValencePoems.add(poem);

      final valStr = el.valenceStr;
      final blankLine = _blankValenceInPoemLine(poem);
      // Skip if blanking didn't actually change the line (edge case)
      if (blankLine == poem) continue;

      q.add(ChemQuestion(
        id: nextId(),
        type: QuestionType.g,
        questionText: blankLine,
        choices: _shuffle4(valStr, _distractors(allValenceStrs, valStr, 3)),
        correctAnswer: valStr,
        elementSymbol: el.symbol,
        poemLine: poem,
        explanation: el.explanation,
      ));
    }

    // ── Type A (exact poem) – Show full atomic-mass poem line with number blanked ─
    // These complement Type A's reformatted version: show the raw line as a quote.
    for (final el in massElements) {
      final mass = el.atomicMassStr;
      final poem = el.atomicMassPoemLine;
      if (poem.isEmpty) continue;
      // Build blank: replace the numeric token in the line
      final blankLine = _blankMassInPoemLine(poem, mass);
      if (blankLine == poem) continue;

      q.add(ChemQuestion(
        id: nextId(),
        type: QuestionType.a,
        questionText: blankLine,
        choices: _shuffle4(mass, _distractors(allMassStrs, mass, 3)),
        correctAnswer: mass,
        elementSymbol: el.symbol,
        poemLine: poem,
        explanation: el.explanation,
      ));
    }

    _cachedAll = q;
    return q;
  }

  /// Returns [count] questions randomly sampled from the full pool.
  static List<ChemQuestion> getQuestionsForDifficulty(GameDifficulty difficulty) {
    final pool = List<ChemQuestion>.from(getAllQuestions());
    pool.shuffle(_rng);
    return pool.take(difficulty.questionCount).toList();
  }

  // ── helpers ─────────────────────────────────────────────────────────────

  /// Extract the short suffix after the number in a poem line.
  static String _poemSuffix(String line) {
    final parts = line.trim().split(' ');
    if (parts.length >= 3) return parts.sublist(2).join(' ');
    return '';
  }

  /// Replace the valence value(s) at the end of a valence poem line with "___".
  /// Looks for the last occurrence of "hóa trị" and blanks everything after it.
  static String _blankValenceInPoemLine(String line) {
    const marker = 'hóa trị';
    final idx = line.lastIndexOf(marker);
    if (idx == -1) return line;
    return '${line.substring(0, idx)}$marker ___';
  }

  /// Replace the atomic-mass number token inside a poem line with "___".
  static String _blankMassInPoemLine(String line, String mass) {
    // Use word-boundary-style replacement (space before & after, or at end).
    if (line.contains(' $mass ')) {
      return line.replaceFirst(' $mass ', ' ___ ');
    }
    if (line.contains(' $mass')) {
      return line.replaceFirst(' $mass', ' ___');
    }
    return line;
  }

  static List<String> _distractors(List<String> pool, String exclude, int n) {
    final filtered = pool.where((e) => e != exclude).toList()..shuffle(_rng);
    return filtered.take(n).toList();
  }

  static String _pickOne(List<String> pool, String exclude) {
    final filtered = pool.where((e) => e != exclude).toList();
    if (filtered.isEmpty) return pool.first;
    return filtered[_rng.nextInt(filtered.length)];
  }

  static List<String> _shuffle4(String correct, List<String> distractors) {
    final choices = <String>[correct, ...distractors.take(3)];
    choices.shuffle(_rng);
    return choices;
  }
}
