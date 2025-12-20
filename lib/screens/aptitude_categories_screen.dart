import 'package:flutter/material.dart';

class AptitudeCategoriesScreen extends StatelessWidget {
  const AptitudeCategoriesScreen({super.key});

  List<Map<String, String>> get categories => const [
        {'id': 'quantitative', 'name': 'Quantitative Aptitude'},
        {'id': 'logical', 'name': 'Logical Reasoning'},
        {'id': 'verbal', 'name': 'Verbal Ability'},
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aptitude Categories')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: categories
              .map((c) => ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/aptitudeLevels', arguments: c),
                    child: Text(c['name']!, textAlign: TextAlign.center),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
