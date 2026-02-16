import 'package:flutter/material.dart';
import '../widgets/global_chat_overlay.dart';
import '../widgets/starfield_background.dart';

class GlobalChatScreen extends StatelessWidget {
  const GlobalChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StarfieldBackground(
        child: Stack(
          children: [
            const SizedBox.expand(),
            GlobalChatOverlay(
              onClose: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
