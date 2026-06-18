class CreateSubstanceRequest {
  final String formula;
  final String name;
  final String? vietnameseName;
  final String type;
  final String chemicalGroup;
  final String state;
  final double? molarMass;
  final bool? active;
  final bool? includedInFullKit;
  final String? description;
  final String? safetyNote;

  CreateSubstanceRequest({
    required this.formula,
    required this.name,
    this.vietnameseName,
    required this.type,
    required this.chemicalGroup,
    required this.state,
    this.molarMass,
    this.active,
    this.includedInFullKit,
    this.description,
    this.safetyNote,
  });

  Map<String, dynamic> toJson() {
    return {
      'formula': formula,
      'name': name,
      if (vietnameseName != null) 'vietnameseName': vietnameseName,
      'type': type,
      'chemicalGroup': chemicalGroup,
      'state': state,
      if (molarMass != null) 'molarMass': molarMass,
      if (active != null) 'active': active,
      if (includedInFullKit != null) 'includedInFullKit': includedInFullKit,
      if (description != null) 'description': description,
      if (safetyNote != null) 'safetyNote': safetyNote,
    };
  }
}