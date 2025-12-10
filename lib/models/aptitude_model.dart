class AptitudeQuestion {
  final String question;
  final String answer;
  const AptitudeQuestion({required this.question, required this.answer});

  factory AptitudeQuestion.fromJson(Map<String, dynamic> json) {
    return AptitudeQuestion(
      question: json['question'] as String,
      answer: json['answer'] as String,
    );
  }
}

class AptitudeTopic {
  final String topic;
  final List<AptitudeQuestion> questions;
  const AptitudeTopic({required this.topic, required this.questions});

  factory AptitudeTopic.fromJson(Map<String, dynamic> json) {
    return AptitudeTopic(
      topic: json['topic'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => AptitudeQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
