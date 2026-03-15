import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/debug_question_model.dart';
import '../services/judge0_service.dart';
import '../services/xp_service.dart';
import '../services/achievement_service.dart';
import '../services/title_service.dart';
import '../theme/retro_theme.dart';
import '../widgets/code_editor_widget.dart';
import '../widgets/debug_console.dart';
import '../widgets/game_hud_appbar.dart';
import '../widgets/starfield_background.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

const _debugFiles = [
  ('Python', 1, 'assets/data/debug/python/level1.json'),
  ('Python', 2, 'assets/data/debug/python/level2.json'),
  ('Java',   1, 'assets/data/debug/java/level1.json'),
  ('Java',   2, 'assets/data/debug/java/level2.json'),
  ('C',      1, 'assets/data/debug/c/level1.json'),
  ('C',      2, 'assets/data/debug/c/level2.json'),
];

const _langOrder = ['Python', 'Java', 'C'];

const _langColor = {
  'Python': Color(0xFF3DDC97),
  'Java':   Color(0xFFFFA04A),
  'C':      Color(0xFF7EB8FF),
};

// ── List screen ───────────────────────────────────────────────────────────────

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  Map<String, Map<int, List<DebugQuestion>>> _grouped = {};
  Set<String> _solvedIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Load questions
    final grouped = <String, Map<int, List<DebugQuestion>>>{};
    for (final (lang, level, path) in _debugFiles) {
      try {
        final jsonStr = await rootBundle.loadString(path);
        final decoded = jsonDecode(jsonStr);
        final List<dynamic> rawList = decoded is List
            ? decoded
            : (decoded is Map<String, dynamic> && decoded['questions'] is List
                ? decoded['questions'] as List
                : <dynamic>[]);
        final questions = rawList
            .whereType<Map<String, dynamic>>()
            .map(DebugQuestion.fromJson)
            .toList();
        grouped.putIfAbsent(lang, () => {})[level] = questions;
      } catch (_) {}
    }

    // Load solved IDs from Firestore
    final solved = <String>{};
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('debugSolved')
            .get();
        solved.addAll(snap.docs.map((d) => d.id));
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _grouped = grouped;
        _solvedIds = solved;
        _loading = false;
      });
    }
  }

  // Called by child to refresh solved state after a solve
  void _markSolved(String id) {
    setState(() => _solvedIds.add(id));
  }

  @override
  Widget build(BuildContext context) {
    // Count progress
    final totalQ = _grouped.values
        .expand((m) => m.values)
        .expand((l) => l)
        .length;
    final solvedCount = _solvedIds.length;

    return Scaffold(
      appBar: const GameHudAppBar(showBack: true, subtitle: 'Debug Console'),
      body: StarfieldBackground(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : (_grouped.isEmpty
                ? const Center(child: Text('No debug questions found'))
                : Column(
                    children: [
                      // ── Progress bar header ──────────────────────────────
                      _ProgressHeader(
                          solved: solvedCount, total: totalQ),
                      // ── Question list ────────────────────────────────────
                      Expanded(
                        child: ListView(
                          padding:
                              const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          children: [
                            for (final lang in _langOrder)
                              if (_grouped.containsKey(lang)) ...[
                                _LanguageHeader(
                                  lang: lang,
                                  color: _langColor[lang] ??
                                      RetroTheme.primary,
                                  solvedCount: _grouped[lang]!.values
                                      .expand((l) => l)
                                      .where((q) =>
                                          _solvedIds.contains(q.id))
                                      .length,
                                  totalCount: _grouped[lang]!.values
                                      .expand((l) => l)
                                      .length,
                                ),
                                for (final level in (_grouped[lang]!
                                        .keys
                                        .toList()
                                      ..sort()))
                                  _LevelSection(
                                    level: level,
                                    questions: _grouped[lang]![level]!,
                                    langColor: _langColor[lang] ??
                                        RetroTheme.primary,
                                    solvedIds: _solvedIds,
                                    onSolve: _markSolved,
                                  ),
                              ],
                          ],
                        ),
                      ),
                    ],
                  )),
      ),
    );
  }
}

// ── Progress header ───────────────────────────────────────────────────────────

class _ProgressHeader extends StatelessWidget {
  final int solved;
  final int total;
  const _ProgressHeader({required this.solved, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : solved / total;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: RetroTheme.primary.withValues(alpha: 0.35),
        ),
        gradient: LinearGradient(
          colors: [
            RetroTheme.primary.withValues(alpha: 0.10),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MISSION PROGRESS',
                style: RetroTheme.hudLabel.copyWith(
                    fontSize: 11, letterSpacing: 2),
              ),
              Text(
                '$solved / $total',
                style: RetroTheme.bodyMono.copyWith(
                  color: RetroTheme.primary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor:
                  RetroTheme.primary.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                RetroTheme.primary.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section widgets ───────────────────────────────────────────────────────────

class _LanguageHeader extends StatelessWidget {
  final String lang;
  final Color  color;
  final int    solvedCount;
  final int    totalCount;

  const _LanguageHeader({
    required this.lang,
    required this.color,
    required this.solvedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                    color: color.withValues(alpha: 0.6),
                    blurRadius: 8,
                    spreadRadius: 1),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              lang.toUpperCase(),
              style: RetroTheme.hudLabel
                  .copyWith(color: color, fontSize: 16, letterSpacing: 3),
            ),
          ),
          // Solved badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              border: Border.all(color: color.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$solvedCount/$totalCount solved',
              style: RetroTheme.bodyMono.copyWith(
                color: color,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelSection extends StatelessWidget {
  final int                    level;
  final List<DebugQuestion>    questions;
  final Color                  langColor;
  final Set<String>            solvedIds;
  final void Function(String)  onSolve;

  const _LevelSection({
    required this.level,
    required this.questions,
    required this.langColor,
    required this.solvedIds,
    required this.onSolve,
  });

  @override
  Widget build(BuildContext context) {
    final levelSolved =
        questions.where((q) => solvedIds.contains(q.id)).length;
    final allDone = levelSolved == questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(top: 12, bottom: 6, left: 4),
          child: Row(
            children: [
              Text(
                '— LEVEL $level',
                style: RetroTheme.hudLabel.copyWith(
                  color: langColor.withValues(alpha: 0.65),
                  fontSize: 11,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 8),
              if (allDone)
                Icon(Icons.check_circle,
                    size: 14,
                    color: langColor.withValues(alpha: 0.8)),
              if (!allDone)
                Text(
                  '$levelSolved/${questions.length}',
                  style: RetroTheme.bodyMono.copyWith(
                    color: langColor.withValues(alpha: 0.45),
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ),
        ...questions.map((q) => _QuestionCard(
              q: q,
              langColor: langColor,
              isSolved: solvedIds.contains(q.id),
              onSolve: onSolve,
            )),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final DebugQuestion          q;
  final Color                  langColor;
  final bool                   isSolved;
  final void Function(String)  onSolve;

  const _QuestionCard({
    required this.q,
    required this.langColor,
    required this.isSolved,
    required this.onSolve,
  });

  @override
  Widget build(BuildContext context) {
    final diffColor = q.difficulty <= 1
        ? const Color(0xFF3DDC97)
        : q.difficulty <= 2
            ? const Color(0xFFFFA04A)
            : const Color(0xFFFF6B6B);

    final borderColor = isSolved
        ? const Color(0xFF3DDC97).withValues(alpha: 0.7)
        : langColor.withValues(alpha: 0.55);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1.5),
        gradient: LinearGradient(
          colors: isSolved
              ? [
                  const Color(0xFF3DDC97).withValues(alpha: 0.08),
                  Colors.transparent,
                ]
              : [
                  langColor.withValues(alpha: 0.10),
                  Colors.transparent,
                ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isSolved
                    ? const Color(0xFF3DDC97)
                    : langColor)
                .withValues(alpha: isSolved ? 0.20 : 0.18),
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        // ── Completion indicator on left ─────────────────────────
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSolved
                ? const Color(0xFF3DDC97).withValues(alpha: 0.15)
                : langColor.withValues(alpha: 0.10),
            border: Border.all(
              color: isSolved
                  ? const Color(0xFF3DDC97).withValues(alpha: 0.8)
                  : langColor.withValues(alpha: 0.40),
              width: 1.5,
            ),
          ),
          child: Icon(
            isSolved ? Icons.check : Icons.code,
            size: 16,
            color: isSolved
                ? const Color(0xFF3DDC97)
                : langColor.withValues(alpha: 0.7),
          ),
        ),
        title: Text(
          q.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isSolved
                    ? Colors.white.withValues(alpha: 0.65)
                    : Colors.white,
                decoration:
                    isSolved ? TextDecoration.none : null,
              ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            children: [
              _Badge(
                  label: 'Diff ${q.difficulty}',
                  color: diffColor),
              const SizedBox(width: 6),
              _Badge(
                  label: '+${q.xp} XP',
                  color: RetroTheme.primary),
              if (isSolved) ...[
                const SizedBox(width: 6),
                _Badge(
                    label: '✓ SOLVED',
                    color: const Color(0xFF3DDC97)),
              ],
            ],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: langColor.withValues(alpha: isSolved ? 0.4 : 0.7),
          size: 15,
        ),
        onTap: () async {
          final didSolve = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => DebugEditorScreen(question: q),
            ),
          );
          if (didSolve == true) onSolve(q.id);
        },
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color  color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.55)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10),
      ),
    );
  }
}

// ── Editor screen ─────────────────────────────────────────────────────────────

class DebugEditorScreen extends StatefulWidget {
  final DebugQuestion question;
  const DebugEditorScreen({super.key, required this.question});

  @override
  State<DebugEditorScreen> createState() => _DebugEditorScreenState();
}

class _DebugEditorScreenState extends State<DebugEditorScreen> {
  late TextEditingController _controller;
  final _judgeService  = Judge0Service();
  final _achievements  = AchievementService();
  final Set<String> _awardedSession = {};

  bool    _isRunning = false;
  int     _runs      = 0;
  String? _stdout;
  String? _stderr;
  String? _status;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.question.starterCode);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    setState(() {
      _isRunning = true;
      _runs++;
      _stdout = null;
      _stderr = null;
      _status = 'Running...';
    });

    try {
      bool   allPassed = true;
      String outputLog = '';

      for (var tc in widget.question.testCases) {
        final result = await _judgeService.submitCode(
          language:       widget.question.language,
          sourceCode:     _controller.text,
          stdin:          tc.input,
          expectedOutput: tc.output,
        );

        final stdout     = result['stdout']              as String? ?? '';
        final stderr     = result['stderr']              as String? ?? '';
        final statusDesc =
            result['status']['description'] as String? ?? 'Unknown';

        if (statusDesc != 'Accepted' ||
            stdout.trim() != tc.output.trim()) {
          allPassed = false;
          _stderr =
              'Test Failed:\nInput: ${tc.input}\nExpected: ${tc.output}\nGot: $stdout\nError: $stderr';
          break;
        } else {
          outputLog +=
              'Test Passed: Input "${tc.input}" -> Output "$stdout"\n';
        }
      }

      if (allPassed) {
        _stdout = 'All Test Cases Passed!\n\n$outputLog';
        _status = 'Success';
        await _handleSuccess();
      } else {
        _status = 'Failed';
      }
    } catch (e) {
      _stderr = 'Error: $e';
      _status = 'Error';
    } finally {
      if (mounted) setState(() => _isRunning = false);
    }
  }

  Future<void> _handleSuccess() async {
    final qid      = widget.question.id;
    if (_awardedSession.contains(qid)) return;

    // Capture context-dependent objects before any async gap
    final xpService = mounted ? context.read<XPService>() : null;
    final uid       = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      final ref = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('debugSolved')
          .doc(qid);
      final snap = await ref.get();
      if (snap.exists) return;
      _awardedSession.add(qid);
      await xpService?.addXP(widget.question.xp);
      await _achievements.recordDebugSolve(firstAttempt: _runs == 1);
      await AchievementService().recordXPUpdated();
      await TitleService().recalculateTitle();
      await ref.set({'solved': true, 'ts': FieldValue.serverTimestamp()});
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '🎉 ${widget.question.title} Solved! +${widget.question.xp} XP'),
          backgroundColor: const Color(0xFF1A2A1A),
        ),
      );
      // Pop back with true so the list screen can mark it solved
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          GameHudAppBar(showBack: true, subtitle: widget.question.title),
      body: StarfieldBackground(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.question.problem,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: CodeEditorWidget(
                        controller: _controller,
                        language:   widget.question.language,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            DebugConsole(
              stdout:    _stdout,
              stderr:    _stderr,
              status:    _status,
              isRunning: _isRunning,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isRunning ? null : _run,
                  child: _isRunning
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child:
                              CircularProgressIndicator(strokeWidth: 2))
                      : const Text('RUN CODE'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
