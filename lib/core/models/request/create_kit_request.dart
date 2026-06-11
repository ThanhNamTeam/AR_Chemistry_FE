class CreateKitRequest {
  final String code;
  final String name;
  final String? description;
  final double? price;
  final bool? active;
  final List<String>? substanceFormulas;

  const CreateKitRequest({
    required this.code,
    required this.name,
    this.description,
    this.price,
    this.active,
    this.substanceFormulas,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      if (description != null && description!.trim().isNotEmpty)
        'description': description,
      if (price != null) 'price': price,
      if (active != null) 'active': active,
      if (substanceFormulas != null && substanceFormulas!.isNotEmpty)
        'substanceFormulas': substanceFormulas,
    };
  }
}