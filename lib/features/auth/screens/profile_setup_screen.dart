import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _studyLevelController;

  @override
  void initState() {
    super.initState();
    final profile = AppScope.of(context).profile;
    _displayNameController = TextEditingController(
      text: profile?.displayName == 'Student' ? '' : profile?.displayName,
    );
    _studyLevelController = TextEditingController(text: profile?.studyLevel);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _studyLevelController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    await AppScope.of(context).saveProfile(
      displayName: _displayNameController.text,
      studyLevel: _studyLevelController.text,
    );
    if (!mounted || AppScope.of(context).errorMessage != null) return;
    Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Setup')),
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
          if (AppScope.of(context).errorMessage case final message?)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                message,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ElevatedButton(
            onPressed: AppScope.of(context).isBusy ? null : _saveProfile,
            child: const Text('Save and continue'),
          ),
        ],
      ),
    );
  }
}
