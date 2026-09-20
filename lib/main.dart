import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_scope.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LoopinBootstrap());
}

class LoopinBootstrap extends StatefulWidget {
  const LoopinBootstrap({super.key});

  @override
  State<LoopinBootstrap> createState() => _LoopinBootstrapState();
}

class _LoopinBootstrapState extends State<LoopinBootstrap> {
  late Future<AppScope> _scopeFuture;

  @override
  void initState() {
    super.initState();
    _scopeFuture = _createScope();
  }

  Future<AppScope> _createScope() => AppScope.create(child: const LoopinApp());

  void _retry() {
    setState(() => _scopeFuture = _createScope());
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AppScope>(
    future: _scopeFuture,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return _StartupError(onRetry: _retry);
      }
      if (!snapshot.hasData) return const _StartupLoading();
      return snapshot.data!;
    },
  );
}

class _StartupLoading extends StatelessWidget {
  const _StartupLoading();

  @override
  Widget build(BuildContext context) => const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: Color(0xFF104B41),
      body: Center(child: CircularProgressIndicator(color: Color(0xFFBCEBDD))),
    ),
  );
}

class _StartupError extends StatelessWidget {
  const _StartupError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: const Color(0xFFF5F9F7),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.sync_problem_outlined,
                size: 52,
                color: Color(0xFF167A67),
              ),
              const SizedBox(height: 16),
              const Text(
                'LOOPIN could not start',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please try again. Your local study data has not been changed.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
