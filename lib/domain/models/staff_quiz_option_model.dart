class StaffQuizOptionModel {
  final String optionKey;
  final String optionText;
  final int optionOrder;

  const StaffQuizOptionModel({
    required this.optionKey,
    required this.optionText,
    required this.optionOrder,
  });

  factory StaffQuizOptionModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return StaffQuizOptionModel(
      optionKey: json['optionKey']?.toString() ?? '',
      optionText: json['optionText']?.toString() ?? '',
      optionOrder:
      (json['optionOrder'] as num?)?.toInt() ?? 0,
    );
  }
}