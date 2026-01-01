import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/retro_theme.dart';

class CodeEditorWidget extends StatelessWidget {
  final TextEditingController controller;
  final String language;
  final bool readOnly;

  const CodeEditorWidget({
    super.key,
    required this.controller,
    required this.language,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: RetroTheme.primary.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: RetroTheme.primary.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.terminal, color: RetroTheme.primary, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      language.toUpperCase(),
                      style: GoogleFonts.sourceCodePro(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _dot(Colors.red),
                    const SizedBox(width: 6),
                    _dot(Colors.yellow),
                    const SizedBox(width: 6),
                    _dot(Colors.green),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              maxLines: null,
              expands: true,
              style: GoogleFonts.sourceCodePro(
                color: const Color(0xFFD4D4D4),
                fontSize: 14,
                height: 1.5,
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(16),
                border: InputBorder.none,
                hintText: '// Write your code here...',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
