import 'package:flutter/foundation.dart';

class StudentReactionModel {
  final String reactionId;
  final String reactionCode;
  final String reactionName;
  final String equation;

  final int grade;
  final String reactionCategory;
  final String reactionType;
  final String arSceneKey;

  final String? description;

  final bool hasPublishedQuiz;
  final int questionCount;
  final int durationSeconds;

  final bool completed;
  final bool hasRunningAttempt;
  final String? activeAttemptCode;
  final int? remainingSeconds;
  final String? latestCompletedAttemptCode;
  final bool canStart;
  final bool canContinue;
  final bool canViewHistory;
  final bool canRetry;

  const StudentReactionModel({
    required this.reactionId,
    required this.reactionCode,
    required this.reactionName,
    required this.equation,
    required this.grade,
    required this.reactionCategory,
    required this.reactionType,
    required this.arSceneKey,
    this.description,
    required this.hasPublishedQuiz,
    required this.questionCount,
    required this.durationSeconds,
    required this.completed,
    required this.hasRunningAttempt,
    this.activeAttemptCode,
    this.remainingSeconds,
    this.latestCompletedAttemptCode,
    required this.canStart,
    required this.canContinue,
    required this.canViewHistory,
    required this.canRetry,
  });

  factory StudentReactionModel.fromJson(
      Map<String, dynamic> json,
      ) {
    debugPrint('[STUDENT-REACTION-MODEL] json=$json');

    return StudentReactionModel(
      reactionId:
      json['reactionId']?.toString() ??
          json['id']?.toString() ??
          '',

      reactionCode:
      json['reactionCode']?.toString() ??
          json['code']?.toString() ??
          '',

      reactionName:
      json['reactionName']?.toString() ??
          json['name']?.toString() ??
          '',

      equation:
      json['equation']?.toString() ?? '',

      grade:
      (json['grade'] as num?)?.toInt() ?? 0,

      reactionCategory:
      json['reactionCategory']?.toString() ?? '',

      reactionType:
      json['reactionType']?.toString() ?? '',

      arSceneKey:
      json['arSceneKey']?.toString() ?? '',

      description:
      json['description']?.toString(),

      hasPublishedQuiz:
      json['hasPublishedQuiz'] as bool? ??
          json['quizAvailable'] as bool? ??
          false,

      questionCount:
      (json['questionCount'] as num?)?.toInt() ?? 0,

      durationSeconds:
      (json['durationSeconds'] as num?)?.toInt() ?? 420,

      completed:
      json['completed'] as bool? ?? false,

      hasRunningAttempt:
      json['hasRunningAttempt'] as bool? ?? false,

      activeAttemptCode:
      json['activeAttemptCode']?.toString(),

      remainingSeconds:
      (json['remainingSeconds'] as num?)?.toInt(),

      latestCompletedAttemptCode:
      json['latestCompletedAttemptCode']?.toString(),

      canStart:
      json['canStart'] as bool? ?? false,

      canContinue:
      json['canContinue'] as bool? ?? false,

      canViewHistory:
      json['canViewHistory'] as bool? ?? false,

      canRetry:
      json['canRetry'] as bool? ?? false,
    );
  }
}