import 'package:supabase_flutter/supabase_flutter.dart';

class AuthFailure implements Exception {
  AuthFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Session? get session => _client.auth.currentSession;
  User? get user => _client.auth.currentUser;
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Future<void> register({
    required String email,
    required String username,
    required String password,
  }) async {
    final available = await _client.rpc(
      'username_available',
      params: {'p_username': username},
    ) as bool;
    if (!available) throw AuthFailure('Ce pseudo est déjà utilisé');

    try {
      await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );
    } on AuthException catch (e) {
      throw AuthFailure(_translate(e));
    }
    await _client.auth.signOut();
  }

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    var email = identifier.trim();

    if (!email.contains('@')) {
      final resolved = await _client.rpc(
        'email_for_username',
        params: {'p_username': email},
      ) as String?;
      if (resolved == null) throw AuthFailure('Identifiants incorrects');
      email = resolved;
    }

    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw AuthFailure(_translate(e));
    }
  }

  Future<void> logout() => _client.auth.signOut();

  String _translate(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login')) return 'Identifiants incorrects';
    if (msg.contains('already registered')) return 'Cet email est déjà utilisé';
    if (msg.contains('weak password')) return 'Mot de passe trop faible';
    return 'Erreur : ${e.message}';
  }

  Future<void> changePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw AuthFailure(_translate(e));
    }
  }

  Future<void> changeUsername(String username) async {
    final available = await _client.rpc(
      'username_available',
      params: {'p_username': username},
    ) as bool;
    if (!available) throw AuthFailure('Ce pseudo est déjà utilisé');

    await _client
        .from('profiles')
        .update({'username': username})
        .eq('id', _client.auth.currentUser!.id);
  }

  Future<void> resetProgress() => _client.rpc('reset_progress');

  Future<void> deleteAccount() async {
    await _client.rpc('delete_account');
    await _client.auth.signOut();
  }
}
