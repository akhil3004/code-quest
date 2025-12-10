import 'package:flutter/material.dart';
import '../models/subject_model.dart';

class McqSubjectsScreen extends StatelessWidget {
  const McqSubjectsScreen({super.key});

  List<SubjectModel> get subjects => const [
        SubjectModel(id: 'os', name: 'Operating Systems'),
        SubjectModel(id: 'dbms', name: 'DBMS'),
        SubjectModel(id: 'cn', name: 'Computer Networks'),
        SubjectModel(id: 'oop', name: 'OOP/Java'),
        SubjectModel(id: 'dsa', name: 'DSA'),
        SubjectModel(id: 'cd', name: 'Compiler Design'),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MCQ Subjects')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: subjects
              .map((s) => ElevatedButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/mcqLevels',
                      arguments: s,
                    ),
                    child: Text(s.name, textAlign: TextAlign.center),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
