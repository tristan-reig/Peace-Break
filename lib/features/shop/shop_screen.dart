import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/shop_item.dart';
import '../../services/profile_controller.dart';
import '../../services/shop_service.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late Future<List<ShopItem>> _future;
  bool _busy = false;

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

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              final affordable = coins >= item.price;

              return Card(
                child: ListTile(
                  leading: Icon(
                    switch (item.kind) {
                      ItemKind.lifePlus => Icons.favorite,
                      ItemKind.paddleSkin => Icons.rectangle,
                      ItemKind.ballSkin => Icons.circle,
                    },
                    color: AppTheme.accent,
                    size: 32,
                  ),
                  title: Text(item.name),
                  subtitle: Text(item.description),
                  trailing: FilledButton(
                    onPressed: (_busy || !affordable)
                        ? null
                        : () => _confirmAndBuy(item),
                    child: Text('${item.price}'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
