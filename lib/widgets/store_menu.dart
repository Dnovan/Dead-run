// lib/widgets/store_menu.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/game/dino_run.dart';
import '/widgets/main_menu.dart';

// --- El Modelo de Datos AHORA SÍ usa la 'description' ---
class StoreItem {
  final int id;
  final String name;
  final String description;
  final int price;
  final String assetPath;
  final String gifPath;

  StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.assetPath,
    required this.gifPath,
  });

  factory StoreItem.fromMap(Map<String, dynamic> map) {
    return StoreItem(
      id: map['id'],
      name: map['name'] ?? '',
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
  late final Future<List<StoreItem>> _futureItems;
  int? _buyingItemId;
  StoreItem? _inspectedItem;

  final String _playerId = 'EL_UUID_QUE_GENERASTE_Y_GUARDASTE';

  @override
  void initState() {
    super.initState();
    _futureItems = _fetchStoreItems();
  }

  Future<List<StoreItem>> _fetchStoreItems() async {
    final response =
        await Supabase.instance.client.from('store_items').select();
    final List<StoreItem> items = (response as List<dynamic>).map((itemData) {
      return StoreItem.fromMap(itemData as Map<String, dynamic>);
    }).toList();
    return items;
  }

  Future<void> _buyItem(StoreItem item) async {
    if (_buyingItemId != null) return;
    setState(() {
      _buyingItemId = item.id;
    });

    try {
      final result = await Supabase.instance.client.rpc('buy_item', params: {
        'item_to_buy': item.id,
        'buyer_id': _playerId,
      });

      if (mounted) {
        final snackBar = SnackBar(
          content: Text(result.toString()),
          backgroundColor: result == 'Éxito' ? Colors.green : Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      if (mounted) {
        final snackBar = SnackBar(
          content: Text('Ocurrió un error de red: ${e.toString()}'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } finally {
      if (mounted) {
        setState(() {
          _buyingItemId = null;
        });
      }
    }
  }

  Widget _buildStoreList(List<StoreItem> items) {
    return Column(
      children: [
        const Text('Tienda', style: TextStyle(fontFamily: 'Audiowide', fontSize: 50, color: Colors.white, shadows: [Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(2, 2))])),
        const Divider(color: Colors.white30, thickness: 2, height: 40),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                onTap: () => setState(() => _inspectedItem = item),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      SizedBox(width: 64, height: 64, child: Image.asset(item.gifPath, filterQuality: FilterQuality.none)),
                      const SizedBox(width: 20),
                      Expanded(child: Text(item.name, style: const TextStyle(fontSize: 22, color: Colors.white))),
                      Text('${item.price} monedas', style: const TextStyle(fontSize: 18, color: Colors.white70)),
                      const SizedBox(width: 20),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF33D1FF).withOpacity(0.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                        onPressed: () => setState(() => _inspectedItem = item),
                        child: const Text('Inspeccionar', style: TextStyle(fontSize: 16, color: Colors.white)),
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
  
  Widget _buildInspectView(StoreItem item) {
    final isBuyingThisItem = _buyingItemId == item.id;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          item.name,
          style: const TextStyle(fontFamily: 'Audiowide', fontSize: 50, color: Colors.white, shadows: [Shadow(blurRadius: 10.0, color: Colors.black)]),
        ),
        const SizedBox(height: 30),
        SizedBox(width: 200, height: 200, child: Image.asset(item.gifPath, filterQuality: FilterQuality.none, fit: BoxFit.contain)),
        const SizedBox(height: 20),
        SizedBox(
          width: 500,
          child: Text(
            item.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 20, 
                color: Colors.white70, 
                fontStyle: FontStyle.italic,
                shadows: [Shadow(blurRadius: 4.0, color: Colors.black)],
            ),
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ActionButton(
              text: 'Comprar (${item.price} monedas)',
              onPressed: (_buyingItemId != null) ? null : () => _buyItem(item),
              child: isBuyingThisItem ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : null,
            ),
            const SizedBox(width: 20),
            _ActionButton(text: 'Cerrar', onPressed: () => setState(() => _inspectedItem = null)),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xCC0A1724),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15, spreadRadius: 5)],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _inspectedItem == null 
              ? FutureBuilder<List<StoreItem>>(
                  future: _futureItems,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    return _buildStoreList(snapshot.data ?? []);
                  },
                )
              : _buildInspectView(_inspectedItem!),
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
      style: TextButton.styleFrom(backgroundColor: const Color(0xFF33D1FF).withOpacity(0.2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
      onPressed: onPressed,
      child: child ?? Text(text, style: const TextStyle(fontSize: 18, color: Colors.white)),
    );
  }
}