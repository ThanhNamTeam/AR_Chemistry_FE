class ReactionCheckResponse {
  const ReactionCheckResponse({
    required this.matched,
    required this.reason,
    required this.message,
    required this.affectedQrPayloads,
    required this.affectedFormulas,
    required this.reactantFormulas,
    this.reactionCode,
    this.equation,
  });

  final bool matched;
  final String reason;
  final String message;
  final String? reactionCode;
  final String? equation;
  final List<String> affectedQrPayloads;
  final List<String> affectedFormulas;
  final List<String> reactantFormulas;

  factory ReactionCheckResponse.fromJson(Map<String, dynamic> json) {
    List<String> strings(Object? value) => value is List
        ? value.whereType<String>().toList(growable: false)
        : const <String>[];

    final reactants = json['reactants'];
    final reactantFormulas = reactants is List
        ? reactants
              .whereType<Map>()
              .map((item) => item['formula'])
              .whereType<String>()
              .toList(growable: false)
        : const <String>[];

    final matched = json['matched'];
    final reason = json['reason'];
    final message = json['message'];
    if (matched is! bool || reason is! String || message is! String) {
      throw const FormatException('Invalid reaction-check response');
    }

    return ReactionCheckResponse(
      matched: matched,
      reason: reason,
      message: message,
      reactionCode: json['reactionCode'] as String?,
      equation: json['equation'] as String?,
      affectedQrPayloads: strings(json['affectedQrPayloads']),
      affectedFormulas: strings(json['affectedFormulas']),
      reactantFormulas: reactantFormulas,
    );
  }

  Map<String, Object?> toBridgeJson() => <String, Object?>{
    'matched': matched,
    'reason': reason,
    'message': message,
    if (reactionCode != null) 'reactionCode': reactionCode,
    if (equation != null) 'equation': equation,
    'affectedQrPayloads': affectedQrPayloads,
    'affectedFormulas': affectedFormulas,
    'reactantFormulas': reactantFormulas,
  };
}
