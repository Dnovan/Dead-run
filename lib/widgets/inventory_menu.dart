import 'package:flutter/material.dart';

import '../game/dino_run.dart';
import 'main_menu.dart';

// Represents the inventory menu overlay.
class InventoryMenu extends StatelessWidget {
  // An unique identified for this overlay.
  static const id = 'InventoryMenu';

  final DinoRun game;

  const InventoryMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withAlpha(100),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No hay nada guardado por el momento',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                game.overlays.remove(id);
                game.overlays.add(MainMenu.id);
              },
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}
