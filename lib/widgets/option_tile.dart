import 'package:flutter/material.dart';
import '../theme/star_wars_retro_theme.dart';

class OptionTile extends StatefulWidget {
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
  State<OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<OptionTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    Color borderColor = StarWarsRetroColors.primaryNeon.withValues(alpha: 0.3);
    Color backgroundColor = Colors.transparent;
    Color textColor = StarWarsRetroColors.textSoft;

    if (widget.selected) {
      if (widget.correct) {
        borderColor = StarWarsRetroColors.primaryNeon;
        backgroundColor = StarWarsRetroColors.primaryNeon.withValues(alpha: 0.2);
      } else {
        borderColor = StarWarsRetroColors.dangerRed;
        backgroundColor = StarWarsRetroColors.dangerRed.withValues(alpha: 0.2);
      }
    } else if (_hovered) {
      borderColor = StarWarsRetroColors.accentPurple;
      backgroundColor = StarWarsRetroColors.accentPurple.withValues(alpha: 0.1);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(30), // Pill style
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              if (widget.selected || _hovered)
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              if (widget.selected)
                Icon(
                  widget.correct ? Icons.check_circle : Icons.cancel,
                  color: widget.correct ? StarWarsRetroColors.primaryNeon : StarWarsRetroColors.dangerRed,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
