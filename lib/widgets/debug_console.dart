import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/retro_theme.dart';

class DebugConsole extends StatelessWidget {
  final String? stdout;
  final String? stderr;
  final String? status;
  final bool isRunning;

  const DebugConsole({
    super.key,
    this.stdout,
    this.stderr,
    this.status,
    this.isRunning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: RetroTheme.primary.withValues(alpha: 0.5))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'CONSOLE OUTPUT',
                style: GoogleFonts.pressStart2p(color: RetroTheme.accent, fontSize: 10),
              ),
              const Spacer(),
              if (isRunning)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2, color: RetroTheme.primary),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (isRunning)
            Text('> Executing...', style: GoogleFonts.vt323(color: Colors.grey, fontSize: 16))
          else if (stderr != null && stderr!.isNotEmpty)
            Text(stderr!, style: GoogleFonts.vt323(color: RetroTheme.error, fontSize: 16))
          else if (stdout != null && stdout!.isNotEmpty)
            Text(stdout!, style: GoogleFonts.vt323(color: RetroTheme.primary, fontSize: 16))
          else if (status != null)
            Text('> $status', style: GoogleFonts.vt323(color: Colors.grey, fontSize: 16))
          else
            Text('> Ready', style: GoogleFonts.vt323(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}
