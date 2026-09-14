import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/shop_item.dart';

class ShopFailure implements Exception {
  ShopFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

class ShopService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<ShopItem>> availableItems() async {
    final userId = _client.auth.currentUser!.id;

    final owned = await _client
        .from('inventory')
        .select('item_id')
        .eq('user_id', userId);
    final ownedIds = owned.map((row) => row['item_id'] as String).toSet();

    final rows = await _client.from('items').select().order('price');

    return rows
        .map(ShopItem.fromMap)
        .where(
          (item) =>
              item.kind == ItemKind.lifePlus || !ownedIds.contains(item.id),
        )
        .toList(growable: false);
  }

  Future<void> purchase(String itemId) async {
    try {
      await _client.rpc('purchase_item', params: {'p_item_id': itemId});
    } on PostgrestException catch (e) {
      throw ShopFailure(_translate(e.message));
    }
  }

  String _translate(String message) {
    if (message.contains('insufficient funds')) {
      return 'Tu n\'as pas assez de pièces';
    }
    if (message.contains('already owned')) return 'Tu possèdes déjà cet objet';
    return 'Achat impossible, réessaie';
  }
}
