import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/shop_item.dart';

class InventoryEntry {
  const InventoryEntry({required this.item, required this.equipped});

  final ShopItem item;
  final bool equipped;
}

class EquippedSkins {
  const EquippedSkins({this.paddle, this.ball});
  final String? paddle;
  final String? ball;
}

class InventoryService {
  final SupabaseClient _client = Supabase.instance.client;

  String get _userId => _client.auth.currentUser!.id;

  Future<List<InventoryEntry>> owned() async {
    final rows = await _client
        .from('inventory')
        .select('equipped, items(id, name, description, price, kind)')
        .eq('user_id', _userId);

    return rows
        .map(
          (row) => InventoryEntry(
            item: ShopItem.fromMap(row['items'] as Map<String, dynamic>),
            equipped: row['equipped'] as bool,
          ),
        )
        .where((entry) => entry.item.kind != ItemKind.lifePlus)
        .toList(growable: false);
  }

  Future<EquippedSkins> equipped() async {
    final rows = await _client
        .from('inventory')
        .select('item_id, kind')
        .eq('user_id', _userId)
        .eq('equipped', true);

    String? paddle;
    String? ball;
    for (final row in rows) {
      if (row['kind'] == 'paddle_skin') paddle = row['item_id'] as String;
      if (row['kind'] == 'ball_skin') ball = row['item_id'] as String;
    }
    return EquippedSkins(paddle: paddle, ball: ball);
  }

  Future<void> equip(ShopItem item) async {
    final kind = item.kind == ItemKind.paddleSkin ? 'paddle_skin' : 'ball_skin';

    await _client
        .from('inventory')
        .update({'equipped': false})
        .eq('user_id', _userId)
        .eq('kind', kind);

    await _client
        .from('inventory')
        .update({'equipped': true})
        .eq('user_id', _userId)
        .eq('item_id', item.id);
  }

  Future<void> unequip(ShopItem item) async {
    await _client
        .from('inventory')
        .update({'equipped': false})
        .eq('user_id', _userId)
        .eq('item_id', item.id);
  }
}
