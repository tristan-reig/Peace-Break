import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/shop_item.dart';
import '../../services/profile_controller.dart';
import '../../services/shop_service.dart';
import '../game/skins.dart';
import '../game/widgets/skin_preview.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late Future<List<ShopItem>> _future;
  bool _busy = false;

  ShopItem? _selected;

  @override
  void initState() {
    super.initState();
    _future = ShopService().availableItems();
  }

  void _reload() {
    setState(() {
      _future = ShopService().availableItems();
    });
  }

  Future<void> _confirmAndBuy(ShopItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer l\'achat'),
        content: Text('Acheter « ${item.name} » pour ${item.price} pièces ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Oui'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final profiles = context.read<ProfileController>();

    setState(() => _busy = true);
    try {
      await ShopService().purchase(item.id);
      await profiles.load();
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('${item.name} acheté !')));
      _reload();
    } on ShopFailure catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Achat impossible, vérifie ton réseau')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coins = context.watch<ProfileController>().profile?.coins ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Boutique'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.monetization_on,
                  size: 20,
                  color: AppTheme.accent,
                ),
                const SizedBox(width: 4),
                Text(
                  '$coins',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<ShopItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Chargement impossible'),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _reload,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final items = snapshot.data ?? const [];
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Tu possèdes déjà tout ce que propose la boutique.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final selected = items.contains(_selected) ? _selected! : items.first;
          final affordable = coins >= selected.price;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (selected.kind == ItemKind.lifePlus)
                      Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppTheme.gameBg,
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.favorite,
                                size: 52,
                                color: AppTheme.magenta,
                              ),
                              SizedBox(height: 8),
                              Text('+1 vie permanente'),
                            ],
                          ),
                        ),
                      )
                    else
                      SkinScene(
                        paddle: selected.kind == ItemKind.paddleSkin
                            ? paddleStyle(selected.id)
                            : kDefaultPaddleStyle,
                        ball: selected.kind == ItemKind.ballSkin
                            ? ballStyle(selected.id)
                            : kDefaultBallStyle,
                        showPaddle: selected.kind == ItemKind.paddleSkin,
                        showBall: selected.kind == ItemKind.ballSkin,
                      ),
                    const SizedBox(height: 12),
                    Text(
                      selected.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selected.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: (_busy || !affordable)
                          ? null
                          : () => _confirmAndBuy(selected),
                      icon: const Icon(Icons.monetization_on, size: 18),
                      label: Text(
                        affordable
                            ? 'Acheter — ${selected.price}'
                            : 'Pièces insuffisantes (${selected.price})',
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _ItemTile(
                      item: item,
                      selected: item.id == selected.id,
                      affordable: coins >= item.price,
                      onTap: () => setState(() => _selected = item),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.item,
    required this.selected,
    required this.affordable,
    required this.onTap,
  });

  final ShopItem item;
  final bool selected;
  final bool affordable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.panel,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? AppTheme.accent : AppTheme.greenDim,
              width: selected ? 2.5 : 1,
            ),
          ),
          child: Opacity(
            opacity: affordable ? 1 : 0.45,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (item.kind == ItemKind.lifePlus)
                  const Icon(Icons.favorite, size: 30, color: AppTheme.magenta)
                else
                  SkinThumb(
                    style: item.kind == ItemKind.ballSkin
                        ? ballStyle(item.id)
                        : paddleStyle(item.id),
                    isBall: item.kind == ItemKind.ballSkin,
                    size: 44,
                  ),
                const SizedBox(height: 2),
                Text(
                  '${item.price}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
