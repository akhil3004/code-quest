import 'package:flutter/material.dart';
import '../theme/star_wars_retro_theme.dart';
import 'global_chat_overlay.dart';

class FloatingChatButton extends StatelessWidget {
  const FloatingChatButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: StarWarsRetroColors.surfaceDark,
        shape: BoxShape.circle,
        border: Border.all(
          color: StarWarsRetroColors.primaryNeon,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: StarWarsRetroColors.primaryNeon.withValues(alpha: 0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              barrierColor: Colors.transparent,
              builder: (context) => GlobalChatOverlay(
                onClose: () => Navigator.of(context).pop(),
              ),
            );
          },
          customBorder: const CircleBorder(),
          child: const Center(
            child: Icon(
              Icons.chat_bubble_outline,
              color: StarWarsRetroColors.primaryNeon,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
