import 'package:flutter/material.dart';

class XPProgressBar extends StatelessWidget {
  final int xp;
  const XPProgressBar({super.key, required this.xp});

  @override
  Widget build(BuildContext context) {
    final current = xp % 100;
    final progress = current / 100.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: progress),
        const SizedBox(height: 8),
        Text('XP: $xp  •  To next level: ${100 - current}')
      ],
    );
  }
}
