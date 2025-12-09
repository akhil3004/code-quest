import 'package:flutter/material.dart';

class OptionTile extends StatelessWidget {
  final String text;
  final bool selected;
  final bool correct;
  final VoidCallback onTap;
  const OptionTile({
    super.key,
    required this.text,
    required this.selected,
    required this.correct,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color? color;
    if (selected) {
      color = correct ? Colors.green[100] : Colors.red[100];
    }
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(text),
      ),
    );
  }
}
