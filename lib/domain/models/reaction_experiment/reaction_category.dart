enum ReactionCategory {
  metal,
  acid,
  base,
  salt;

  String get storageKey => name;

  static ReactionCategory? fromKey(String? key) {
    if (key == null) return null;
    for (final c in ReactionCategory.values) {
      if (c.name == key) return c;
    }
    return null;
  }
}
