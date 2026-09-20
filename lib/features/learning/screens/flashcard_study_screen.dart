import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../study/models/study_models.dart';
import 'flashcard_match_screen.dart';

class FlashcardStudyScreen extends StatefulWidget {
  const FlashcardStudyScreen({
    required this.cardSet,
    this.dueOnly = false,
    super.key,
  });
  final FlashcardSet cardSet;
  final bool dueOnly;

  @override
  State<FlashcardStudyScreen> createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen> {
  late final List<Flashcard> _cards;
  int _index = 0;
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now().toUtc();
    _cards = widget.dueOnly
        ? widget.cardSet.cards
              .where(
                (card) =>
                    card.nextReviewAt == null ||
                    !card.nextReviewAt!.isAfter(now),
              )
              .toList()
        : [...widget.cardSet.cards];
  }

  Future<void> _next() async {
    if (_index == _cards.length - 1) {
      await AppScope.studyOf(context).markFlashcardsStudied(widget.cardSet);
      if (mounted) Navigator.pop(context);
      return;
    }
    setState(() {
      _index++;
      _showAnswer = false;
    });
  }

  Future<void> _rate(bool remembered) async {
    await AppScope.studyOf(context).reviewFlashcardById(
      set: widget.cardSet,
      cardId: _cards[_index].id,
      remembered: remembered,
    );
    if (mounted) await _next();
  }

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No cards are due right now.')),
      );
    }
    final card = _cards[_index];
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dueOnly ? 'Due review' : widget.cardSet.title),
        actions: [
          if (!widget.dueOnly && _cards.length > 1)
            IconButton(
              tooltip: 'Match practice',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FlashcardMatchScreen(cardSet: widget.cardSet),
                ),
              ),
              icon: const Icon(Icons.extension_outlined),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          LinearProgressIndicator(
            value: (_index + 1) / _cards.length,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 12),
          Text(
            'Card ${_index + 1} of ${_cards.length}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => setState(() => _showAnswer = !_showAnswer),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: Container(
                key: ValueKey(_showAnswer),
                constraints: const BoxConstraints(minHeight: 300),
                width: double.infinity,
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: _showAnswer
                      ? theme.colorScheme.primaryContainer
                      : Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _showAnswer
                          ? Icons.lightbulb_outline
                          : Icons.style_outlined,
                      size: 42,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _showAnswer ? card.back : card.front,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _showAnswer
                          ? 'Tap to see the prompt'
                          : 'Tap to reveal the answer',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_showAnswer)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rate(false),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Review again'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _rate(true),
                    icon: const Icon(Icons.check),
                    label: const Text('I knew it'),
                  ),
                ),
              ],
            )
          else
            FilledButton.icon(
              onPressed: () => setState(() => _showAnswer = true),
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('Reveal answer'),
            ),
        ],
      ),
    );
  }
}
