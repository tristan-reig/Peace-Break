enum ItemKind { lifePlus, paddleSkin, ballSkin }

ItemKind _kindFromString(String value) => switch (value) {
  'life_plus' => ItemKind.lifePlus,
  'paddle_skin' => ItemKind.paddleSkin,
  _ => ItemKind.ballSkin,
};

class ShopItem {
  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.kind,
  });

  final String id;
  final String name;
  final String description;
  final int price;
  final ItemKind kind;

  factory ShopItem.fromMap(Map<String, dynamic> map) => ShopItem(
    id: map['id'] as String,
    name: map['name'] as String,
    description: map['description'] as String,
    price: map['price'] as int,
    kind: _kindFromString(map['kind'] as String),
  );
}
