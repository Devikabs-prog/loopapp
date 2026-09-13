import 'package:flutter/material.dart';

import '../../../core/app_state.dart';
import '../../dashboard/home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _displayNameController = TextEditingController(
    text: AppState.displayName == 'Student' ? '' : AppState.displayName,
  );

  final _studyLevelController = TextEditingController(
    text: AppState.studyLevel,
  );

  @override
  void dispose() {
    _displayNameController.dispose();
    _studyLevelController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final displayName = _displayNameController.text.trim();
    final studyLevel = _studyLevelController.text.trim();

    AppState.displayName = displayName.isEmpty ? 'Student' : displayName;
    AppState.studyLevel = studyLevel;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Setup'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Profile setup',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'This is the next screen after login/sign up. Later we will add study level, preferences, avatar setup, and subjects.',
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _displayNameController,
            decoration: const InputDecoration(
              labelText: 'Display name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _studyLevelController,
            decoration: const InputDecoration(
              labelText: 'Study level',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveProfile,
            child: const Text('Save and continue'),
          ),
        ],
      ),
    );
  }
}