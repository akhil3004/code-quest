class UserModel {
  final String uid;
  final String username;
  final int xp;
  final int level;
  final String title;
  final int streak;

  UserModel({
    required this.uid,
    required this.username,
    required this.xp,
    required this.level,
    required this.title,
    required this.streak,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      username: json['username'] as String,
      xp: (json['xp'] ?? 0) as int,
      level: (json['level'] ?? 0) as int,
      title: (json['title'] ?? 'Rookie Coder') as String,
      streak: (json['streak'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'xp': xp,
      'level': level,
      'title': title,
      'streak': streak,
    };
  }
}
