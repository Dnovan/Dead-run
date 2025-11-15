// lib/widgets/store_menu.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../game/dino_run.dart';
import '../models/player_data.dart';
import 'main_menu.dart';

class StoreItem {
  final int id;
  final String name;
  final String description;
  final int price;
  final String assetPath;
  final String gifPath;

  StoreItem({
    required this.id, required this.name, required this.description,
    required this.price, required this.assetPath, required this.gifPath
  });

  factory StoreItem.fromMap(Map<String, dynamic> map) {
    return StoreItem(
      id: map['id'], name: map['name'] ?? '',
      description: map['description'] ?? 'Una skin misteriosa.',
      price: map['price'] ?? 0,
      assetPath: map['asset_path'] ?? '',
      gifPath: map['gif_path'] ?? '',
    );
  }
}

class StoreMenu extends StatefulWidget {
  static const String id = 'StoreMenu';
  final DinoRun game;

  const StoreMenu(this.game, {super.key});

  @override
  State<StoreMenu> createState() => _StoreMenuState();
}

class _StoreMenuState extends State<StoreMenu> {
  late Future<List<dynamic>> _futureData;
  int? _buyingItemId;
  StoreItem? _inspectedItem;
  
  // ¡¡IMPORTANTE!! Pega aquí el UUID de tu jugador que creaste en Supabase.
  final String _playerId = '5836c3f4-9378-4e31-94c1-78e52482de34'; 

  @override
  void initState() {
    super.initState();
    _futureData = _fetchStoreAndInventory();
  }

  Future<List<dynamic>> _fetchStoreAndInventory() {
    final storeItemsFuture = Supabase.instance.client.from('store_items').select();
    final inventoryFuture = Supabase.instance.client.from('player_inventory').select('item_id').eq('player_id', _playerId);
    return Future.wait([storeItemsFuture, inventoryFuture]);
  }

  // FUNCIÓN _buyItem() CORREGIDA PARA EVITAR EL ERROR DE 'setState'.
  Future<void> _buyItem(StoreItem item) async {
    if (widget.game.playerData.coins < item.price) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Monedas insuficientes.'), backgroundColor: Colors.red));
      return;
    }
    
    setState(() => _buyingItemId = item.id);
    
    try {
      final result = await Supabase.instance.client.rpc('buy_item', params: {'item_to_buy': item.id, 'buyer_id': _playerId});
      
      if (mounted) {
        if ((result as String).startsWith('¡Éxito')) {
          widget.game.playerData.coins -= item.price;
          widget.game.playerData.save();
          setState(() => _futureData = _fetchStoreAndInventory());
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result.toString()), 
          backgroundColor: result.startsWith('¡Éxito') ? Colors.green : Colors.amber)
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error de red: ${e.toString()}'), backgroundColor: Colors.red));
      }
    } 

    if (mounted) {
      setState(() => _buyingItemId = null);
    }
  }

  Widget _buildStoreList(List<StoreItem> items, List<int> ownedItemIds) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Tienda', style: TextStyle(fontFamily: 'Audiowide', fontSize: 50, color: Colors.white, shadows: [Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(2, 2))])),
            Consumer<PlayerData>(
              builder: (context, playerData, child) => Row(children: [
                const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 24),
                const SizedBox(width: 10),
                Text('${playerData.coins}', style: const TextStyle(fontSize: 24, color: Colors.white, fontFamily: 'Audiowide')),
              ]),
            ),
          ],
        ),
        const Divider(color: Colors.white30, thickness: 2, height: 40),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final ownsItem = ownedItemIds.contains(item.id);
              return InkWell(
                onTap: () => setState(() => _inspectedItem = item),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      SizedBox(width: 64, height: 64, child: Image.asset(item.gifPath, filterQuality: FilterQuality.none)),
                      const SizedBox(width: 20),
                      Expanded(child: Text(item.name, style: const TextStyle(fontSize: 22, color: Colors.white, shadows: [Shadow(blurRadius: 4.0, color: Colors.black)]))),
                      Text('${item.price} monedas', style: const TextStyle(fontSize: 18, color: Colors.white70, shadows: [Shadow(blurRadius: 4.0, color: Colors.black)])),
                      const SizedBox(width: 20),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: ownsItem ? Colors.white24 : const Color(0xFF33D1FF).withAlpha((255 * 0.2).round()),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                        onPressed: () => setState(() => _inspectedItem = item),
                        child: Text(ownsItem ? 'Poseído' : 'Inspeccionar', style: TextStyle(fontSize: 16, color: ownsItem ? Colors.white54 : Colors.white)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(color: Colors.white30, thickness: 2, height: 40),
        _MenuButton(text: 'Volver', onPressed: () {
          widget.game.overlays.remove(StoreMenu.id);
          widget.game.overlays.add(MainMenu.id);
        }),
      ],
    );
  }
  
  Widget _buildInspectView(StoreItem item, List<int> ownedItemIds) {
    final isBuyingThisItem = _buyingItemId == item.id;
    final ownsItem = ownedItemIds.contains(item.id);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(item.name, style: const TextStyle(fontFamily: 'Audiowide', fontSize: 50, color: Colors.white, shadows: [Shadow(blurRadius: 10.0, color: Colors.black)])),
        const SizedBox(height: 30),
        SizedBox(width: 200, height: 200, child: Image.asset(item.gifPath, filterQuality: FilterQuality.none, fit: BoxFit.contain)),
        const SizedBox(height: 20),
        SizedBox(
          width: 500,
          child: Text(
            item.description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, color: Colors.white70, fontStyle: FontStyle.italic, shadows: [Shadow(blurRadius: 4.0, color: Colors.black)]),
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!ownsItem) 
              _ActionButton(
                text: 'Comprar (${item.price} monedas)',
                onPressed: (_buyingItemId != null) ? null : () => _buyItem(item),
                child: isBuyingThisItem ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : null,
              ),
            if (ownsItem) 
              const Text('Ya posees esta skin', style: TextStyle(fontSize: 18, color: Colors.greenAccent, shadows: [Shadow(blurRadius: 4.0, color: Colors.black)])),
            const SizedBox(width: 20),
            _ActionButton(text: 'Cerrar', onPressed: () => setState(() => _inspectedItem = null)),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.game.playerData,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xCC0A1724),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withAlpha((255 * 0.2).round())),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha((255 * 0.5).round()), blurRadius: 15, spreadRadius: 5)],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: FutureBuilder<List<dynamic>>(
                key: ValueKey(_futureData),
                future: _futureData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.white));
                  if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
                  
                  final storeItems = (snapshot.data?[0] as List? ?? []).map((data) => StoreItem.fromMap(data)).toList();
                  final ownedItemIds = (snapshot.data?[1] as List? ?? []).map((data) => data['item_id'] as int).toList();
                  
                  return _inspectedItem == null
                      ? _buildStoreList(storeItems, ownedItemIds)
                      : _buildInspectView(_inspectedItem!, ownedItemIds);
                },
              ),
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
        foregroundColor: Colors.white.withAlpha((255 * 0.9).round()),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
        overlayColor: Colors.white.withAlpha((255 * 0.1).round()),
      ),
      child: Text(text, style: const TextStyle(fontFamily: 'Audiowide', fontSize: 28.0, shadows: [Shadow(blurRadius: 8.0, color: Colors.black, offset: Offset(2, 2))])),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? child;

  const _ActionButton({required this.text, this.onPressed, this.child});
  
  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(backgroundColor: const Color(0xFF33D1FF).withAlpha((255 * 0.2).round()), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
      onPressed: onPressed,
      child: child ?? Text(text, style: const TextStyle(fontSize: 18, color: Colors.white)),
    );
  }
}