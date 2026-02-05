import 'package:flutter/material.dart';
import '../theme/star_wars_retro_theme.dart';

class QuestionCard extends StatelessWidget {
  final String question;
  final List<Widget> options;
  const QuestionCard({super.key, required this.question, required this.options});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Card(
          color: StarWarsRetroColors.surfaceDark.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: StarWarsRetroColors.accentPurple.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  question,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: StarWarsRetroColors.textSoft,
                        height: 1.3,
                        fontSize: 20,
                        letterSpacing: 0.5,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ...options,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
