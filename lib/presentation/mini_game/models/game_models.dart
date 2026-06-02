import 'package:flutter/material.dart';

enum QuestionType { a, b, c, d, e, f, g, h, i, j }

enum GameDifficulty { easy, medium, hard }

extension GameDifficultyExt on GameDifficulty {
  String get label {
    switch (this) {
      case GameDifficulty.easy:
        return 'Dễ';
      case GameDifficulty.medium:
        return 'Trung bình';
      case GameDifficulty.hard:
        return 'Khó';
    }
  }

  int get questionCount {
    switch (this) {
      case GameDifficulty.easy:
        return 20;
      case GameDifficulty.medium:
        return 30;
      case GameDifficulty.hard:
        return 40;
    }
  }

  Color get color {
    switch (this) {
      case GameDifficulty.easy:
        return const Color(0xFF22C55E);
      case GameDifficulty.medium:
        return const Color(0xFFF59E0B);
      case GameDifficulty.hard:
        return const Color(0xFFEF4444);
    }
  }

  String get description {
    switch (this) {
      case GameDifficulty.easy:
        return '20 câu hỏi';
      case GameDifficulty.medium:
        return '30 câu hỏi';
      case GameDifficulty.hard:
        return '40 câu hỏi';
    }
  }
}

class ChemQuestion {
  final String id;
  final QuestionType type;
  final String questionText;
  final List<String> choices;
  final String correctAnswer;
  final String elementSymbol;
  final String poemLine;
  final String explanation;

  const ChemQuestion({
    required this.id,
    required this.type,
    required this.questionText,
    required this.choices,
    required this.correctAnswer,
    required this.elementSymbol,
    required this.poemLine,
    required this.explanation,
  });
}

class UserAnswer {
  final ChemQuestion question;
  final String? selectedAnswer;

  const UserAnswer({required this.question, this.selectedAnswer});

  bool get isCorrect => selectedAnswer == question.correctAnswer;
  bool get isAnswered => selectedAnswer != null;
}
