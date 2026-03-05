import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/star_wars_retro_theme.dart';
import '../services/ai_assistant_service.dart';

class FloatingChatButton extends StatelessWidget {
  final String screen;

  const FloatingChatButton({super.key, this.screen = 'home'});

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
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (sheetContext) {
                return AiAssistantPanel(
                  screen: screen,
                );
              },
            );
          },
          customBorder: const CircleBorder(),
          child: const Center(
            child: Icon(
              Icons.smart_toy_outlined,
              color: StarWarsRetroColors.primaryNeon,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

class AiAssistantPanel extends StatefulWidget {
  final String screen;

  const AiAssistantPanel({super.key, required this.screen});

  @override
  State<AiAssistantPanel> createState() => _AiAssistantPanelState();
}

class _AiAssistantPanelState extends State<AiAssistantPanel> {
  final AiAssistantService _service = AiAssistantService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  int _remaining = 10;
  final List<_AiMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    // Pre-load a themed welcome message from the AI
    _messages.add(
      _AiMessage(
        fromUser: false,
        text: '🚀 Greetings, cadet! I\'m your Code Quest AI co-pilot.\n\n'
            'Whether you need a hint, a code explanation, or just want to understand a concept — I\'ve got your back.\n\n'
            'What\'s your mission today?',
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending || _remaining <= 0) return;

    setState(() {
      _isSending = true;
      _remaining -= 1;
      _messages.add(
        _AiMessage(
          fromUser: true,
          text: text,
        ),
      );
      _controller.clear();
    });

    try {
      final reply = await _service.sendMessage(
        message: text,
        screen: widget.screen,
      );
      if (!mounted) return;
      setState(() {
        _messages.add(
          _AiMessage(
            fromUser: false,
            text: reply,
          ),
        );
      });
      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          color: StarWarsRetroColors.surfaceDark.withValues(alpha: 0.95),
          border: Border.all(
            color: StarWarsRetroColors.primaryNeon.withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: StarWarsRetroColors.primaryNeon.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.smart_toy_outlined,
                        color: StarWarsRetroColors.primaryNeon,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Code Quest AI',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: StarWarsRetroColors.textBright,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '$_remaining/10',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: StarWarsRetroColors.textSoft,
                            ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    // +1 slot for typing indicator when sending
                    itemCount: _messages.length + (_isSending ? 1 : 0),
                    itemBuilder: (context, index) {
                      // The top slot (index 0 in reversed list) = typing indicator
                      if (_isSending && index == 0) {
                        return const Align(
                          alignment: Alignment.centerLeft,
                          child: _TypingIndicator(),
                        );
                      }
                      final msgIndex = _messages.length -
                          1 -
                          (index - (_isSending ? 1 : 0));
                      final msg = _messages[msgIndex];
                      return Align(
                        alignment: msg.fromUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: msg.fromUser
                                ? StarWarsRetroColors.primaryNeon
                                : Colors.white.withValues(alpha: 0.05),
                            border: Border.all(
                              color: msg.fromUser
                                  ? StarWarsRetroColors.primaryNeon
                                      .withValues(alpha: 0.6)
                                  : StarWarsRetroColors.accentPurple
                                      .withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            msg.text,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: msg.fromUser
                                      ? Colors.black
                                      : StarWarsRetroColors.textBright,
                                ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          maxLines: 3,
                          minLines: 1,
                          decoration: InputDecoration(
                            hintText: _remaining > 0
                                ? 'Ask for a hint or explanation...'
                                : 'Session limit reached',
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.04),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: StarWarsRetroColors.primaryNeon
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                          enabled: _remaining > 0 && !_isSending,
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: _isSending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(
                                Icons.send,
                                color: StarWarsRetroColors.primaryNeon,
                              ),
                        onPressed:
                            _remaining > 0 && !_isSending ? _send : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AiMessage {
  final bool fromUser;
  final String text;

  _AiMessage({
    required this.fromUser,
    required this.text,
  });
}

// ── Typing indicator: three pulsing neon dots ──────────────────────────────
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: StarWarsRetroColors.accentPurple.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              // Stagger each dot by 0.3 of the cycle
              final phase = (_controller.value - i * 0.28).clamp(0.0, 1.0);
              final scale = 0.6 +
                  0.4 *
                      math.sin(phase * math.pi).clamp(0.0, 1.0);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 7 * scale,
                height: 7 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: StarWarsRetroColors.primaryNeon
                      .withValues(alpha: 0.4 + 0.6 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: StarWarsRetroColors.primaryNeon
                          .withValues(alpha: 0.3 * scale),
                      blurRadius: 6,
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
