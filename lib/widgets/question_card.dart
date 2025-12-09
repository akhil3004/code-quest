import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  final String question;
  final List<Widget> options;
  const QuestionCard({super.key, required this.question, required this.options});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...options,
          ],
        ),
      ),
    );
  }
}
