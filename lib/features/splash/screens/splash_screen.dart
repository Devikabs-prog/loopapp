import 'dart:async';

import 'package:flutter/material.dart';

import '../../auth/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _navigationTimer = Timer(const Duration(milliseconds: 2600), _openLogin);
  }

  void _openLogin() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 650),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fadeIn = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.18, 0.72, curve: Curves.easeOut),
    );
    final wordmarkFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.42, 0.9, curve: Curves.easeOut),
    );

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A2925), Color(0xFF104B41), Color(0xFF0A2925)],
            stops: [0, 0.5, 1],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _BackgroundPattern(),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  FadeTransition(
                    opacity: fadeIn,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale = 0.96 + (_pulseController.value * 0.04);
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: const _LoopLogo(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  FadeTransition(
                    opacity: wordmarkFade,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.18),
                        end: Offset.zero,
                      ).animate(wordmarkFade),
                      child: const Column(
                        children: [
                          Text(
                            'LOOPIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 7,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Make progress a habit.',
                            style: TextStyle(
                              color: Color(0xB8D8EEE8),
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 4),
                  FadeTransition(
                    opacity: wordmarkFade,
                    child: const _LoadingIndicator(),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'YOUR STUDY JOURNEY, IN A LOOP',
                    style: TextStyle(
                      color: Color(0x80D8EEE8),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoopLogo extends StatelessWidget {
  const _LoopLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 142,
      height: 142,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFBCEBDD), Color(0xFF65C6A7)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF65C6A7).withValues(alpha: 0.28),
            blurRadius: 32,
            spreadRadius: 6,
          ),
        ],
      ),
      child: const Icon(
        Icons.all_inclusive_rounded,
        color: Color(0xFF0B4038),
        size: 88,
      ),
    );
  }
}

class _LoadingIndicator extends StatefulWidget {
  const _LoadingIndicator();

  @override
  State<_LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<_LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 4,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _LoadingPainter(progress: _controller.value),
          );
        },
      ),
    );
  }
}

class _LoadingPainter extends CustomPainter {
  const _LoadingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()
      ..color = const Color(0x40D8EEE8)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.height;
    final progressPaint = Paint()
      ..color = const Color(0xFFD8EEE8)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.height;

    canvas.drawLine(Offset.zero, Offset(size.width, 0), trackPaint);
    final x = (size.width - 10) * progress;
    canvas.drawLine(Offset(x, 0), Offset(x + 10, 0), progressPaint);
  }

  @override
  bool shouldRepaint(_LoadingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _BackgroundPattern extends StatelessWidget {
  const _BackgroundPattern();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: CustomPaint(painter: _PatternPainter()));
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x16BCEBDD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = -2; i < 6; i++) {
      final offset = i * 94.0;
      canvas.drawCircle(
        Offset(size.width * 0.86, size.height * 0.18 + offset),
        92 + (i.abs() * 12),
        paint,
      );
    }

    final dotPaint = Paint()..color = const Color(0x26BCEBDD);
    for (var row = 0; row < 8; row++) {
      for (var column = 0; column < 5; column++) {
        canvas.drawCircle(
          Offset(28 + (column * 26), 44 + (row * 28)),
          1.5,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
