class ReactionDefinitionModel {
  final String id;
  final String code;
  final String name;
  final String equation;
  final String? reactionType;
  final String? arSceneKey;
  final String? description;
  final bool active;

  const ReactionDefinitionModel({
    required this.id,
    required this.code,
    required this.name,
    required this.equation,
    this.reactionType,
    this.arSceneKey,
    this.description,
    required this.active,
  });

  factory ReactionDefinitionModel.fromJson(Map<String, dynamic> json) {
    return ReactionDefinitionModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      equation: json['equation']?.toString() ?? '',
      reactionType: json['reactionType']?.toString(),
      arSceneKey: json['arSceneKey']?.toString(),
      description: json['description']?.toString(),
      active: json['active'] == true,
    );
  }
}