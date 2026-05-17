enum QuizDraftStatus { pendingReview, approved, rejected }

class QuizDraftModel {
  final String id;
  final String title;
  final String topic;
  final String sourceDocument;
  final QuizDraftStatus status;
  final String? staffNote;
  final DateTime createdAt;

  QuizDraftModel({
    required this.id,
    required this.title,
    required this.topic,
    required this.sourceDocument,
    required this.status,
    this.staffNote,
    required this.createdAt,
  });

  QuizDraftModel copyWith({
    QuizDraftStatus? status,
    String? staffNote,
  }) {
    return QuizDraftModel(
      id: id,
      title: title,
      topic: topic,
      sourceDocument: sourceDocument,
      status: status ?? this.status,
      staffNote: staffNote ?? this.staffNote,
      createdAt: createdAt,
    );
  }
}
