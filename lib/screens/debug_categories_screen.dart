import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DebugCategoriesScreen extends StatefulWidget {
  const DebugCategoriesScreen({super.key});
  @override
  State<DebugCategoriesScreen> createState() => _DebugCategoriesScreenState();
}

class _DebugCategoriesScreenState extends State<DebugCategoriesScreen> {
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final str = await rootBundle.loadString('assets/data/debug/basic.json');
      final data = jsonDecode(str) as List<dynamic>;
      setState(() {
        _categories = ['basic'];
      });
    } catch (_) {
      setState(() => _categories = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Categories')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final c = _categories[index];
          return ListTile(
            title: Text(c),
            subtitle: const Text('Python & C supported'),
            trailing: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/debug'),
              child: const Text('Open'),
            ),
          );
        },
      ),
    );
  }
}
