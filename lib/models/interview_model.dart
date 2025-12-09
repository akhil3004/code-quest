class QAPair {
  final String question;
  final String answer;

  QAPair({required this.question, required this.answer});

  factory QAPair.fromJson(Map<String, dynamic> json) {
    return QAPair(
      question: json['question'] as String,
      answer: json['answer'] as String,
    );
  }
}

class InterviewTopic {
  final String topic;
  final List<QAPair> items;

  InterviewTopic({required this.topic, required this.items});

  factory InterviewTopic.fromJson(Map<String, dynamic> json) {
    return InterviewTopic(
      topic: json['topic'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => QAPair.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
