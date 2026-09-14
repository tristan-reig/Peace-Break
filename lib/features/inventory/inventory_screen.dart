import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../models/shop_item.dart';
import '../../services/inventory_service.dart';
import '../game/skins.dart';
import '../game/widgets/skin_preview.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late Future<List<InventoryEntry>> _future;
  bool _busy = false;

  InventoryEntry? _selected;

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
      _selected = null;
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

          final equippedPaddle = entries
              .where((e) => e.equipped && e.item.kind == ItemKind.paddleSkin)
              .firstOrNull;
          final equippedBall = entries
              .where((e) => e.equipped && e.item.kind == ItemKind.ballSkin)
              .firstOrNull;

          final preview = _selected;
          final showPaddle = preview?.item.kind == ItemKind.paddleSkin
              ? preview!.item.id
              : equippedPaddle?.item.id;
          final showBall = preview?.item.kind == ItemKind.ballSkin
              ? preview!.item.id
              : equippedBall?.item.id;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SkinScene(
                      paddle: paddleStyle(showPaddle),
                      ball: ballStyle(showBall),
                      showPaddle:
                          preview == null ||
                          preview.item.kind == ItemKind.paddleSkin,
                      showBall:
                          preview == null ||
                          preview.item.kind == ItemKind.ballSkin,
                    ),
                    const SizedBox(height: 12),
                    if (preview == null)
                      const Text(
                        'Choisis un objet pour le prévisualiser',
                        style: TextStyle(fontSize: 13, color: Colors.white54),
                      )
                    else ...[
                      Text(
                        preview.item.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        preview.equipped ? 'Équipé' : 'Non équipé',
                        style: TextStyle(
                          fontSize: 12,
                          color: preview.equipped
                              ? Colors.lightGreenAccent
                              : Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 10),
                      preview.equipped
                          ? OutlinedButton(
                              onPressed: _busy ? null : () => _toggle(preview),
                              child: const Text('Retirer'),
                            )
                          : FilledButton(
                              onPressed: _busy ? null : () => _toggle(preview),
                              child: const Text('Équiper'),
                            ),
                    ],
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
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final isBall = entry.item.kind == ItemKind.ballSkin;
                    final isSelected = _selected?.item.id == entry.item.id;

                    return Material(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() => _selected = entry),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: entry.equipped
                                  ? Colors.lightGreenAccent
                                  : (isSelected
                                        ? AppTheme.accent
                                        : Colors.white24),
                              width: entry.equipped || isSelected ? 2.5 : 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: SkinThumb(
                                  style: isBall
                                      ? ballStyle(entry.item.id)
                                      : paddleStyle(entry.item.id),
                                  isBall: isBall,
                                  size: 44,
                                ),
                              ),
                              if (entry.equipped)
                                const Positioned(
                                  top: 3,
                                  right: 3,
                                  child: Icon(
                                    Icons.check_circle,
                                    size: 15,
                                    color: Colors.lightGreenAccent,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
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
