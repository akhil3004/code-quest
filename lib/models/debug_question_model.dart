class DebugQuestion {
  final String id;
  final String language; // 'python' or 'c'
  final String prompt;
  final String starterCode;
  final String expectedOutput;

  DebugQuestion({
    required this.id,
    required this.language,
    required this.prompt,
    required this.starterCode,
    required this.expectedOutput,
  });

  factory DebugQuestion.fromJson(Map<String, dynamic> json) {
    return DebugQuestion(
      id: json['id'] as String,
      language: json['language'] as String,
      prompt: json['prompt'] as String,
      starterCode: json['starter_code'] as String,
      expectedOutput: json['expected_output'] as String,
    );
  }
}
