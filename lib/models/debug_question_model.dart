class TestCase {
  final String input;
  final String output;

  TestCase({required this.input, required this.output});

  factory TestCase.fromJson(Map<String, dynamic> json) {
    return TestCase(
      input: json['input'] ?? '',
      output: json['output'] ?? '',
    );
  }
}

class DebugQuestion {
  final String id;
  final String title;
  final int difficulty;
  final String language;
  final String problem;
  final String starterCode;
  final List<TestCase> testCases;
  final bool hidden;
  final int xp;

  DebugQuestion({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.language,
    required this.problem,
    required this.starterCode,
    required this.testCases,
    required this.hidden,
    required this.xp,
  });

  factory DebugQuestion.fromJson(Map<String, dynamic> json) {
    return DebugQuestion(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Untitled',
      difficulty: json['difficulty'] ?? 1,
      language: json['language'] ?? 'python',
      problem: json['problem'] ?? '',
      starterCode: json['starterCode'] ?? '',
      testCases: (json['testCases'] as List<dynamic>?)
              ?.map((e) => TestCase.fromJson(e))
              .toList() ??
          [],
      hidden: json['hidden'] ?? false,
      xp: json['xp'] ?? 10,
    );
  }
}
