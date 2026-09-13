import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Profile> fetch() async {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('Aucun utilisateur connecté');

    final data = await _client
        .from('profiles')
        .select()
        .eq('id', id)
        .single();

    return Profile.fromMap(data);
  }
}
