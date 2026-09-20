import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../study/models/study_models.dart';

class FlashcardMatchScreen extends StatefulWidget {
  const FlashcardMatchScreen({required this.cardSet, super.key});
  final FlashcardSet cardSet;

  @override
  State<FlashcardMatchScreen> createState() => _FlashcardMatchScreenState();
}

class _FlashcardMatchScreenState extends State<FlashcardMatchScreen> {
  late final List<Flashcard> _cards;
  int _index = 0;
  int _score = 0;
  bool _answered = false;
  String? _selected;

  @override
  void initState() {
    super.initState();
    _cards = [...widget.cardSet.cards]..shuffle(Random());
  }

  List<String> get _options {
    final values = <String>{_cards[_index].back};
    final pool = [..._cards]..shuffle(Random(_index + 41));
    for (final card in pool) {
      values.add(card.back);
      if (values.length == min(4, _cards.length)) break;
    }
    return values.toList()..shuffle(Random(_index + 73));
  }

  Future<void> _choose(String answer) async {
    if (_answered) return;
    final correct = answer == _cards[_index].back;
    setState(() {
      _selected = answer;
      _answered = true;
      if (correct) _score++;
    });
    await AppScope.studyOf(context).reviewFlashcard(
      set: widget.cardSet,
      index: widget.cardSet.cards.indexWhere(
        (card) => card.id == _cards[_index].id,
      ),
      remembered: correct,
    );
  }

  void _next() {
    if (_index == _cards.length - 1) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _index++;
      _answered = false;
      _selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = _cards[_index];
    final options = _options;
    return Scaffold(
      appBar: AppBar(title: const Text('Match practice')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Question ${_index + 1} of ${_cards.length}'),
              Text(
                'Score $_score',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: (_index + 1) / _cards.length),
          const SizedBox(height: 28),
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.psychology_outlined, size: 40),
                  const SizedBox(height: 16),
                  Text(
                    card.front,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OutlinedButton(
                onPressed: () => _choose(option),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.centerLeft,
                  side: BorderSide(
                    color: !_answered || _selected != option
                        ? theme.colorScheme.outlineVariant
                        : option == card.back
                        ? Colors.green
                        : theme.colorScheme.error,
                  ),
                ),
                child: Text(option),
              ),
            ),
          ),
          if (_answered) ...[
            Text(
              _selected == card.back
                  ? 'Nice recall.'
                  : 'The correct answer was: ${card.back}',
              style: TextStyle(
                color: _selected == card.back
                    ? Colors.green.shade700
                    : theme.colorScheme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _next,
              icon: Icon(
                _index == _cards.length - 1 ? Icons.check : Icons.arrow_forward,
              ),
              label: Text(_index == _cards.length - 1 ? 'Finish' : 'Next'),
            ),
          ],
        ],
      ),
    );
  }
}
