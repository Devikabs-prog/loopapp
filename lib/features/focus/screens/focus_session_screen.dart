import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../study/models/study_models.dart';

class FocusSessionScreen extends StatefulWidget {
  const FocusSessionScreen({required this.session, super.key});
  final FocusSession session;

  @override
  State<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends State<FocusSessionScreen> {
  Timer? _timer;
  late DateTime _startedAt;
  late int _elapsedBeforePause;
  late bool _paused;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    _startedAt = widget.session.startedAt;
    _elapsedBeforePause = widget.session.elapsedSeconds;
    _paused = widget.session.paused;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _paused) return;
      if (_remainingSeconds <= 0) {
        _finish();
      } else {
        setState(() {});
      }
    });
  }

  int get _totalSeconds => widget.session.durationMinutes * 60;

  int get _elapsedSeconds {
    if (_paused) return _elapsedBeforePause.clamp(0, _totalSeconds);
    return (_elapsedBeforePause +
            DateTime.now().toUtc().difference(_startedAt).inSeconds)
        .clamp(0, _totalSeconds);
  }

  int get _remainingSeconds =>
      (_totalSeconds - _elapsedSeconds).clamp(0, _totalSeconds);

  Future<void> _togglePause() async {
    if (_finishing) return;
    if (_paused) {
      _elapsedBeforePause = _elapsedSeconds;
      _startedAt = DateTime.now().toUtc();
      _paused = false;
    } else {
      _elapsedBeforePause = _elapsedSeconds;
      _paused = true;
    }
    await AppScope.studyOf(context).updateFocus(
      widget.session.copyWith(
        startedAt: _startedAt,
        elapsedSeconds: _elapsedBeforePause,
        paused: _paused,
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _finish() async {
    if (_finishing) return;
    _finishing = true;
    _timer?.cancel();
    final completed = widget.session.copyWith(
      startedAt: _startedAt,
      elapsedSeconds: _elapsedSeconds,
      paused: false,
    );
    await AppScope.studyOf(context).completeFocus(completed);
    if (mounted)
      Navigator.pushReplacementNamed(
        context,
        '/focus-summary',
        arguments: completed,
      );
  }

  Future<void> _cancel() async {
    if (_finishing) return;
    _finishing = true;
    _timer?.cancel();
    await AppScope.studyOf(context).cancelFocus(
      widget.session.copyWith(
        startedAt: _startedAt,
        elapsedSeconds: _elapsedSeconds,
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _remainingSeconds;
    final minutes = (remaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (remaining % 60).toString().padLeft(2, '0');
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus session'),
        leading: IconButton(onPressed: _cancel, icon: const Icon(Icons.close)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final timerSize = (constraints.maxWidth * .72)
              .clamp(190.0, 230.0)
              .toDouble();
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 40,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Stay with the next small step',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.94, end: 1),
                      duration: const Duration(seconds: 2),
                      curve: Curves.easeInOut,
                      builder: (_, scale, child) =>
                          Transform.scale(scale: scale, child: child),
                      child: SizedBox(
                        width: timerSize,
                        height: timerSize,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primaryContainer,
                          ),
                          child: Center(
                            child: FittedBox(
                              child: Text(
                                '$minutes:$seconds',
                                style: theme.textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      _paused ? 'Paused' : 'Focus in progress',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _togglePause,
                          icon: Icon(_paused ? Icons.play_arrow : Icons.pause),
                          label: Text(_paused ? 'Resume' : 'Pause'),
                        ),
                        FilledButton.icon(
                          onPressed: _finish,
                          icon: const Icon(Icons.check),
                          label: const Text('Finish'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
