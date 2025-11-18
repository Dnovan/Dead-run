// lib/widgets/main_menu.dart

import 'package:flutter/material.dart';

import '../game/dino_run.dart';
import 'inventory_menu.dart';
import 'settings_menu.dart';
import 'store_menu.dart';
import 'story_menu.dart';

// No necesita ser StatefulWidget porque 'dino_run.dart' se encarga
// de iniciar la música cuando este menú aparece.
class MainMenu extends StatelessWidget {
  static const id = 'MainMenu';
  final DinoRun game;

  const MainMenu(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dead Run',
              style: TextStyle(
                fontFamily: 'Audiowide',
                fontSize: 60.0,
                color: Colors.white,
                shadows: [
                  Shadow(
                      blurRadius: 12.0,
                      color: Colors.black,
                      offset: Offset(2, 2)),
                ],
              ),
            ),
            const SizedBox(height: 30.0),
            _MenuButton(
              text: 'Modo Historia',
              onPressed: () {
                game.overlays.remove(MainMenu.id);
                game.overlays.add(StoryMenu.id);
              },
            ),
            const SizedBox(height: 10),
            _MenuButton(
              text: 'Modo Arcade',
              onPressed: () {
                // Orden directa al juego: "muestra la selección de nivel".
                game.showLevelSelection();
              },
            ),
            const SizedBox(height: 10),
            _MenuButton(
              text: 'Inventario',
              onPressed: () {
                // Simplemente quitamos este menú y añadimos el del inventario.
                game.overlays.remove(MainMenu.id);
                game.overlays.add(InventoryMenu.id);
              },
            ),
            const SizedBox(height: 10),
            _MenuButton(
              text: 'Tienda',
              onPressed: () {
                game.overlays.remove(MainMenu.id);
                game.overlays.add(StoreMenu.id);
              },
            ),
            const SizedBox(height: 10),
            _MenuButton(
              text: 'Ajustes',
              onPressed: () {
                game.overlays.remove(MainMenu.id);
                game.overlays.add(SettingsMenu.id);
              },
            ),
          ],
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
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        overlayColor: Colors.white.withOpacity(0.1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Audiowide',
          fontSize: 28.0,
          shadows: [
            Shadow(blurRadius: 8.0, color: Colors.black, offset: Offset(2, 2)),
          ],
        ),
      ),
    );
  }
}
