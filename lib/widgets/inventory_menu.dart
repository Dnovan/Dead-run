// lib/widgets/inventory_menu.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../game/dino_run.dart';
import 'main_menu.dart';
import 'store_menu.dart'; // Importamos StoreItem para reutilizar el modelo.

class InventoryMenu extends StatefulWidget {
  static const id = 'InventoryMenu';
  final DinoRun game;

  const InventoryMenu({super.key, required this.game});

  @override
  State<InventoryMenu> createState() => _InventoryMenuState();
}

class _InventoryMenuState extends State<InventoryMenu> {
  late final Future<List<StoreItem>> _futureInventoryItems;
  final String _playerId = 'EL_UUID_QUE_GENERASTE_Y_GUARDASTE';

  @override
  void initState() {
    super.initState();
    _futureInventoryItems = _fetchInventoryItems();
  }

  // ¡AQUÍ ESTÁ LA CORRECCIÓN!
  Future<List<StoreItem>> _fetchInventoryItems() async {
    // 1. Obtenemos los IDs de los items que el jugador posee. (Esta parte estaba bien).
    final inventoryResponse = await Supabase.instance.client
        .from('player_inventory')
        .select('item_id')
        .eq('player_id', _playerId);

    if (inventoryResponse.isEmpty) {
      return [];
    }

    final List<int> itemIds = inventoryResponse.map<int>((item) => item['item_id'] as int).toList();

    // 2. Con esos IDs, obtenemos los detalles completos de los items.
    // SE REEMPLAZA '.in_()' POR '.filter()'.
    final itemsResponse = await Supabase.instance.client
        .from('store_items')
        .select()
        .filter('id', 'in', itemIds); // Usamos 'filter' para construir la consulta "IN".

    return itemsResponse.map<StoreItem>((itemData) => StoreItem.fromMap(itemData)).toList();
  }
  
  void _equipItem(StoreItem item) {
    // TODO: Implementar lógica para actualizar el 'equipped_skin_id' en la tabla 'players'.
    print('Equipando ${item.name}');
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${item.name} equipado!'),
      backgroundColor: Colors.green,
    ));
  }
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xCC0A1724),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15, spreadRadius: 5)],
          ),
          child: Column(
            children: [
              const Text(
                'Inventario',
                style: TextStyle(
                  fontFamily: 'Audiowide',
                  fontSize: 50,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(2, 2))],
                ),
              ),
              const Divider(color: Colors.white30, thickness: 2, height: 40),
              
              Expanded(
                child: FutureBuilder<List<StoreItem>>(
                  future: _futureInventoryItems,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent, fontSize: 18)));
                    }

                    final items = snapshot.data ?? [];

                    if (items.isEmpty) {
                      return const Center(
                        child: Text(
                          'Tu inventario está vacío.\n¡Visita la tienda para adquirir nuevas skins!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Audiowide', fontSize: 24, color: Colors.white70),
                        ),
                      );
                    }
                    
                    return GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        const bool isEquipped = false;
                        
                        return InkWell(
                          onTap: () => _equipItem(item),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isEquipped ? const Color(0xFF33D1FF) : Colors.white24,
                                width: 2,
                              ),
                              color: isEquipped ? const Color(0x3333D1FF) : Colors.transparent,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(item.gifPath, filterQuality: FilterQuality.none),
                                )),
                                Text(
                                  item.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (isEquipped)
                                  const Text('Equipado', style: TextStyle(color: Color(0xFF33D1FF), fontSize: 12)),
                                const SizedBox(height: 5),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const Divider(color: Colors.white30, thickness: 2, height: 40),

              _MenuButton(
                text: 'Volver',
                onPressed: () {
                  widget.game.overlays.remove(InventoryMenu.id);
                  widget.game.overlays.add(MainMenu.id);
                },
              ),
            ],
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