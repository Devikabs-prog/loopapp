import '../../../core/data/local_store.dart';
import '../../../core/models/user_profile.dart';

class AuthRepository {
  AuthRepository(this._store);

  final LocalStore _store;

  UserProfile? get currentUser {
    final id = _store.readSessionId();
    final profile = _store.readProfile();
    return id == null || profile == null ? null : profile;
  }

  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || !email.contains('@') || password.length < 6) {
      throw const FormatException(
        'Enter a valid email and a password with 6+ characters.',
      );
    }
    final existing = _store.readProfile();
    final profile =
        existing ??
        UserProfile(
          id: 'local-${email.trim().toLowerCase()}',
          email: email.trim().toLowerCase(),
          displayName: 'Student',
          studyLevel: '',
        );
    await _store.writeProfile(profile);
    await _store.writeSession(profile.id);
    return profile;
  }

  Future<UserProfile> signUp({
    required String email,
    required String password,
  }) => signIn(email: email, password: password);

  Future<void> signOut() => _store.clearSession();

  Future<UserProfile> saveProfile(UserProfile profile) async {
    await _store.writeProfile(profile);
    await _store.writeSession(profile.id);
    return profile;
  }
}
