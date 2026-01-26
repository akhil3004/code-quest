import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../models/chat_message_model.dart';
import '../services/global_chat_service.dart';
import '../theme/star_wars_retro_theme.dart';
import 'chat_message_bubble.dart';
import 'starfield_background.dart';

class GlobalChatOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const GlobalChatOverlay({super.key, required this.onClose});

  @override
  State<GlobalChatOverlay> createState() => _GlobalChatOverlayState();
}

class _GlobalChatOverlayState extends State<GlobalChatOverlay> {
  final GlobalChatService _chatService = GlobalChatService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    try {
      await _chatService.sendMessage(text);
      _controller.clear();
      // Scroll to bottom
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Glassmorphic background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
          
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: StarWarsRetroColors.background.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: StarWarsRetroColors.primaryNeon.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: StarWarsRetroColors.primaryNeon.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: StarWarsRetroColors.primaryNeon.withValues(alpha: 0.3),
                          ),
                        ),
                        color: StarWarsRetroColors.surfaceDark,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.public, color: StarWarsRetroColors.primaryNeon),
                          const SizedBox(width: 8),
                          Text(
                            'GLOBAL CHAT',
                            style: GoogleFonts.pressStart2p(
                              color: StarWarsRetroColors.primaryNeon,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white70),
                            onPressed: widget.onClose,
                          ),
                        ],
                      ),
                    ),

                    // Chat List
                    Expanded(
                      child: Stack(
                        children: [
                          const StarfieldBackground(child: SizedBox.expand()), 
                          
                          StreamBuilder<List<ChatMessage>>(
                            stream: _chatService.getMessages(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Center(child: Text('Error loading chat', style: GoogleFonts.shareTechMono(color: Colors.white)));
                              }
                              if (!snapshot.hasData) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              final messages = snapshot.data!;
                              if (messages.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No messages yet.\nBe the first!',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.shareTechMono(
                                      color: Colors.white54,
                                    ),
                                  ),
                                );
                              }

                              return ListView.builder(
                                controller: _scrollController,
                                reverse: true,
                                padding: const EdgeInsets.all(16),
                                itemCount: messages.length,
                                itemBuilder: (context, index) {
                                  final msg = messages[index];
                                  final isMe = currentUser != null && msg.userId == currentUser.uid;
                                  return ChatMessageBubble(message: msg, isMe: isMe);
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Input Area
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: StarWarsRetroColors.surfaceDark,
                        border: Border(
                          top: BorderSide(
                            color: StarWarsRetroColors.primaryNeon.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              enabled: currentUser != null,
                              style: GoogleFonts.shareTechMono(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: currentUser != null 
                                    ? 'Type a message...' 
                                    : 'Login to chat',
                                hintStyle: GoogleFonts.shareTechMono(color: Colors.white38),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.05),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: _isSending 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                                : Icon(Icons.send, color: currentUser != null ? StarWarsRetroColors.primaryNeon : Colors.grey),
                            onPressed: currentUser != null ? _sendMessage : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
