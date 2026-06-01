class StaffLessonQuizPromptModel {
  final String lessonCode;
  final String lessonTitle;
  final String? chapter;
  final String content;
  final String prompt;

  const StaffLessonQuizPromptModel({
    required this.lessonCode,
    required this.lessonTitle,
    this.chapter,
    required this.content,
    required this.prompt,
  });

  factory StaffLessonQuizPromptModel.fromJson(Map<String, dynamic> json) {
    return StaffLessonQuizPromptModel(
      lessonCode: json['lessonCode'] as String? ?? '',
      lessonTitle: json['lessonTitle'] as String? ?? '',
      chapter: json['chapter'] as String?,
      content: json['content'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
    );
  }
}