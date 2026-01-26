import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/chat_message_model.dart';
import '../theme/star_wars_retro_theme.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe
              ? StarWarsRetroColors.primaryNeon.withValues(alpha: 0.15)
              : StarWarsRetroColors.surfaceDark.withValues(alpha: 0.8),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(12),
          ),
          border: Border.all(
            color: isMe
                ? StarWarsRetroColors.primaryNeon.withValues(alpha: 0.5)
                : StarWarsRetroColors.accentPurple.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isMe
                  ? StarWarsRetroColors.primaryNeon.withValues(alpha: 0.1)
                  : Colors.transparent,
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.username,
                    style: GoogleFonts.orbitron(
                      color: StarWarsRetroColors.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: StarWarsRetroColors.accentPurple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: StarWarsRetroColors.accentPurple.withValues(alpha: 0.5),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      'Lvl ${message.userLevel}',
                      style: GoogleFonts.shareTechMono(
                        color: StarWarsRetroColors.accentPurple,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                message.userTitle,
                style: GoogleFonts.shareTechMono(
                  color: Colors.white54,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 6),
            ],
            Text(
              message.text,
              style: GoogleFonts.shareTechMono(
                color: Colors.white,
                fontSize: 14,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                DateFormat('HH:mm').format(message.timestamp),
                style: GoogleFonts.shareTechMono(
                  color: Colors.white38,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
