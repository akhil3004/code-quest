class LevelProgressModel {
  final String subject;
  final Map<int, bool> levels; // level -> completed?
  const LevelProgressModel({required this.subject, required this.levels});

  factory LevelProgressModel.fromJson(String subject, Map<String, dynamic>? json) {
    final map = <int, bool>{};
    if (json != null) {
      json.forEach((k, v) {
        final level = int.tryParse(k);
        if (level != null) {
          map[level] = (v as bool?) ?? false;
        }
      });
    }
    return LevelProgressModel(subject: subject, levels: map);
  }

  Map<String, dynamic> toJson() {
    return {for (final e in levels.entries) e.key.toString(): e.value};
  }
}
