// lib/widgets/store_menu.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/game/dino_run.dart';
import '/widgets/main_menu.dart';

// --- Modelo de Datos para un Artículo de la Tienda ---
class StoreItem {
  final int id;
  final String name;
  final int price;
  final String assetPath; // Ruta al spritesheet PNG para el juego
  final String gifPath; // Ruta al GIF animado para la tienda y el inventario

  StoreItem({
    required this.id,
    required this.name,
    required this.price,
    required this.assetPath,
    required this.gifPath,
  });

  factory StoreItem.fromMap(Map<String, dynamic> map) {
    return StoreItem(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      assetPath: map['asset_path'] ?? '',
      gifPath: map['gif_path'] ?? '',
    );
  }
}

// --- Widget de la Pantalla de la Tienda ---
class StoreMenu extends StatefulWidget {
  static const String id = 'StoreMenu';
  final DinoRun game;

  const StoreMenu(this.game, {super.key});

  @override
  State<StoreMenu> createState() => _StoreMenuState();
}

class _StoreMenuState extends State<StoreMenu> {
  late final Future<List<StoreItem>> _futureItems;
  bool _isBuying = false;

  // --- ¡MUY IMPORTANTE! ---
  // Reemplaza esta cadena con el UUID que creaste para tu jugador de prueba.
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
    if (_isBuying) return;
    setState(() {
      _isBuying = true;
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
          _isBuying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withAlpha(100),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Tienda',
                style: TextStyle(fontSize: 48.0, color: Colors.white)),
            const SizedBox(height: 30),
            Expanded(
              child: FutureBuilder<List<StoreItem>>(
                future: _futureItems,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red)));
                  }
                  final items = snapshot.data;
                  if (items == null || items.isEmpty) {
                    return const Center(
                        child: Text('No hay artículos disponibles.',
                            style: TextStyle(color: Colors.white)));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        color: Colors.white.withAlpha(200),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: item.gifPath.isNotEmpty
                                    ? FractionallySizedBox(
                                        widthFactor: 0.8,
                                        heightFactor: 0.8,
                                        child: Image.asset(
                                          item.gifPath,
                                          fit: BoxFit.contain,
                                          // ¡LA CORRECCIÓN PARA EL PIXEL ART!
                                          filterQuality: FilterQuality.none,
                                        ),
                                      )
                                    : const Placeholder(),
                              ),
                            ),
                            Text(item.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('${item.price} monedas'),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    fixedSize: const Size(100, 30)),
                                onPressed:
                                    _isBuying ? null : () => _buyItem(item),
                                child: _isBuying
                                    ? const SizedBox(
                                        height: 15,
                                        width: 15,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2))
                                    : const Text('Comprar'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.game.overlays.remove(StoreMenu.id);
                widget.game.overlays.add(MainMenu.id);
              },
              child: const Text('Volver'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
