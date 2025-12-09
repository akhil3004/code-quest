import 'package:flutter/material.dart';

class TitleBadge extends StatelessWidget {
  final String title;
  const TitleBadge({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(title));
  }
}
