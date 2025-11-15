// lib/widgets/inventory_menu.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../game/dino_run.dart';
import '../models/player_data.dart';
import 'main_menu.dart';
import 'store_menu.dart'; // Reutilizamos el modelo 'StoreItem'

class InventoryMenu extends StatefulWidget {
  static const id = 'InventoryMenu';
  final DinoRun game;

  const InventoryMenu({super.key, required this.game});

  @override
  State<InventoryMenu> createState() => _InventoryMenuState();
}

class _InventoryMenuState extends State<InventoryMenu> {
  late Future<List<StoreItem>> _futureInventoryItems;
  StoreItem? _inspectedItem;
  final String _playerId = '5836c3f4-9378-4e31-94c1-78e52482de34';

  @override
  void initState() {
    super.initState();
    _futureInventoryItems = _fetchInventoryItems();
  }

  Future<List<StoreItem>> _fetchInventoryItems() async {
    final inventoryResponse = await Supabase.instance.client.from('player_inventory').select('item_id').eq('player_id', _playerId);
    if (inventoryResponse.isEmpty) return [];
    final List<int> itemIds = inventoryResponse.map<int>((item) => item['item_id'] as int).toList();
    final itemsResponse = await Supabase.instance.client.from('store_items').select().filter('id', 'in', itemIds);
    return itemsResponse.map<StoreItem>((itemData) => StoreItem.fromMap(itemData)).toList();
  }

  Future<void> _equipItem(StoreItem item) async {
    widget.game.playerData.setEquippedSkin(item.assetPath);
    try {
      await Supabase.instance.client.from('players').update({'equipped_skin_id': item.id}).eq('id', _playerId);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.name} equipado!'), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al equipar: $e'), backgroundColor: Colors.red));
    }
  }

  // Vista de la cuadrícula de skins poseídas.
  Widget _buildInventoryGrid(List<StoreItem> items, PlayerData playerData) {
    return Column(
      children: [
        const Text('Inventario',
          style: TextStyle(fontFamily: 'Audiowide', fontSize: 40, color: Colors.white, shadows: [Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(2, 2))]),
        ),
        const Divider(color: Colors.white30, thickness: 2, height: 20),
        Expanded(
          child: items.isEmpty
              ? const Center(
                  child: Text(
                    'Tu inventario está vacío.\n¡Visita la tienda para adquirir nuevas skins!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Audiowide', fontSize: 20, color: Colors.white70),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 por fila en móvil
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isEquipped = playerData.equippedSkinAssetPath == item.assetPath;
                    return Tooltip(
                      message: item.name,
                      child: InkWell(
                        onTap: () => setState(() => _inspectedItem = item),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isEquipped ? const Color(0xFF33D1FF) : Colors.white24, width: 2),
                            color: isEquipped ? const Color(0x3333D1FF) : Colors.transparent,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(child: Padding(padding: const EdgeInsets.all(8.0), child: Image.asset(item.gifPath, filterQuality: FilterQuality.none))),
                              if (isEquipped) const Text('Equipado', style: TextStyle(color: Color(0xFF33D1FF), fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        const Divider(color: Colors.white30, thickness: 2, height: 20),
        _MenuButton(text: 'Volver', onPressed: () {
          widget.game.overlays.remove(InventoryMenu.id);
          widget.game.overlays.add(MainMenu.id);
        }),
      ],
    );
  }

  // Vista de inspección con scroll.
  Widget _buildInspectView(StoreItem item) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(item.name, style: const TextStyle(fontFamily: 'Audiowide', fontSize: 40, color: Colors.white, shadows: [Shadow(blurRadius: 10.0, color: Colors.black)])),
          const SizedBox(height: 20),
          SizedBox(width: 150, height: 150, child: Image.asset(item.gifPath, filterQuality: FilterQuality.none, fit: BoxFit.contain)),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              item.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white70, fontStyle: FontStyle.italic, shadows: [Shadow(blurRadius: 4.0, color: Colors.black)]),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ActionButton(text: 'Equipar', onPressed: () => _equipItem(item)),
              const SizedBox(width: 20),
              _ActionButton(text: 'Cerrar', onPressed: () => setState(() => _inspectedItem = null)),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.game.playerData,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0xCC0A1724),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15, spreadRadius: 5)],
            ),
            child: Consumer<PlayerData>(
              builder: (context, playerData, child) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _inspectedItem == null
                      ? FutureBuilder<List<StoreItem>>(
                          key: ValueKey('inventory_grid'),
                          future: _futureInventoryItems,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.white));
                            if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent, fontSize: 18)));
                            return _buildInventoryGrid(snapshot.data ?? [], playerData);
                          },
                        )
                      : Container(
                          key: ValueKey(_inspectedItem!.id),
                          child: _buildInspectView(_inspectedItem!),
                      ),
                );
              }
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const _MenuButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white.withOpacity(0.9),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
        overlayColor: Colors.white.withOpacity(0.1),
      ),
      child: Text(text, style: const TextStyle(fontFamily: 'Audiowide', fontSize: 24.0, shadows: [Shadow(blurRadius: 8.0, color: Colors.black, offset: Offset(2, 2))])),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const _ActionButton({required this.text, this.onPressed});
  
  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(backgroundColor: const Color(0xFF33D1FF).withOpacity(0.2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(fontSize: 16, color: Colors.white)),
    );
  }
}