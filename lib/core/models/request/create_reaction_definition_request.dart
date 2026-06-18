// lib/core/models/request/create_reaction_definition_request.dart

class CreateReactionDefinitionRequest {
  final String code;
  final String name;
  final String equation;
  final String reactionType;
  final String arSceneKey;
  final String description;
  final bool active;
  final List<ReactionSubstanceRequest> reactants;
  final List<ReactionSubstanceRequest> products;

  CreateReactionDefinitionRequest({
    required this.code,
    required this.name,
    required this.equation,
    required this.reactionType,
    required this.arSceneKey,
    required this.description,
    required this.active,
    required this.reactants,
    required this.products,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'equation': equation,
      'reactionType': reactionType,
      'arSceneKey': arSceneKey,
      'description': description,
      'active': active,
      'reactants': reactants.map((e) => e.toJson()).toList(),
      'products': products.map((e) => e.toJson()).toList(),
    };
  }
}

class ReactionSubstanceRequest {
  final String formula;
  final int coefficient;

  ReactionSubstanceRequest({
    required this.formula,
    required this.coefficient,
  });

  Map<String, dynamic> toJson() {
    return {
      'formula': formula,
      'coefficient': coefficient,
    };
  }
}