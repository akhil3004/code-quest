class MCQQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  MCQQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });

  factory MCQQuestion.fromJson(Map<String, dynamic> json) {
    return MCQQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>).map((e) => e as String).toList(),
      correctIndex: json['correctIndex'] as int,
      explanation: json['explanation'] as String?,
    );
  }
}
