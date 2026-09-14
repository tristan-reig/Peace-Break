import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/leaderboard_entry.dart';

class LeaderboardData {
  const LeaderboardData({required this.top, required this.me});

  final List<LeaderboardEntry> top;

  final LeaderboardEntry? me;
}

class LeaderboardService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<LeaderboardData> fetch() async {
    final userId = _client.auth.currentUser!.id;

    final topRows = await _client
        .from('leaderboard')
        .select()
        .order('rank', ascending: true)
        .limit(10);

    final top = topRows.map(LeaderboardEntry.fromMap).toList(growable: false);

    if (top.any((entry) => entry.userId == userId)) {
      return LeaderboardData(top: top, me: null);
    }

    final mine = await _client
        .from('leaderboard')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return LeaderboardData(
      top: top,
      me: mine == null ? null : LeaderboardEntry.fromMap(mine),
    );
  }
}
