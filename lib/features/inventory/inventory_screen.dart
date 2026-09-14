import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../models/shop_item.dart';
import '../../services/inventory_service.dart';
import '../game/skins.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late Future<List<InventoryEntry>> _future;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _future = InventoryService().owned();
  }

  void _reload() {
    setState(() {
      _future = InventoryService().owned();
    });
  }

  Future<void> _toggle(InventoryEntry entry) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      if (entry.equipped) {
        await InventoryService().unequip(entry.item);
      } else {
        await InventoryService().equip(entry.item);
      }
      _reload();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Opération impossible, réessaie')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventaire')),
      body: FutureBuilder<List<InventoryEntry>>(
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

          final entries = snapshot.data ?? const [];
          if (entries.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Ton inventaire est vide.\n'
                  'Achète des skins dans la boutique.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final paddles = entries
              .where((e) => e.item.kind == ItemKind.paddleSkin)
              .toList();
          final balls = entries
              .where((e) => e.item.kind == ItemKind.ballSkin)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (paddles.isNotEmpty) ...[
                const _SectionTitle('Raquettes'),
                ...paddles.map(_tile),
                const SizedBox(height: 24),
              ],
              if (balls.isNotEmpty) ...[
                const _SectionTitle('Balles'),
                ...balls.map(_tile),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _tile(InventoryEntry entry) {
    final isBall = entry.item.kind == ItemKind.ballSkin;
    final color = isBall
        ? ballColor(entry.item.id)
        : paddleColor(entry.item.id);

    return Card(
      child: ListTile(
        leading: Container(
          width: 40,
          height: isBall ? 40 : 16,
          decoration: BoxDecoration(
            color: color,
            shape: isBall ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isBall ? null : BorderRadius.circular(4),
          ),
        ),
        title: Text(entry.item.name),
        subtitle: Text(entry.equipped ? 'Équipé' : 'Non équipé'),
        trailing: entry.equipped
            ? OutlinedButton(
                onPressed: _busy ? null : () => _toggle(entry),
                child: const Text('Retirer'),
              )
            : FilledButton(
                onPressed: _busy ? null : () => _toggle(entry),
                child: const Text('Équiper'),
              ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.accent,
      ),
    ),
  );
}
