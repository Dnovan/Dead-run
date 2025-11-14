// lib/widgets/main_menu.dart

import 'package:flutter/material.dart';

import '/game/dino_run.dart';
import '/game/audio_manager.dart';
import '/widgets/inventory_menu.dart';
import '/widgets/level_selection_menu.dart';
import '/widgets/settings_menu.dart';
import '/widgets/store_menu.dart';

class MainMenu extends StatefulWidget {
  static const id = 'MainMenu';
  final DinoRun game;

  const MainMenu(this.game, {super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  void initState() {
    super.initState();
    AudioManager.instance.startBgm('8BitPlatformerLoop.wav');
  }

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
                  Shadow(blurRadius: 12.0, color: Colors.black, offset: Offset(2, 2)),
                ],
              ),
            ),
            const SizedBox(height: 30.0),

            _MenuButton(
              text: 'Jugar',
              onPressed: () {
                widget.game.overlays.add(LevelSelectionMenu.id);
                widget.game.overlays.remove(MainMenu.id);
              },
            ),
            const SizedBox(height: 10),

            _MenuButton(
              text: 'Inventario',
              onPressed: () {
                widget.game.overlays.add(InventoryMenu.id);
                widget.game.overlays.remove(MainMenu.id);
              },
            ),
            const SizedBox(height: 10),

            _MenuButton(
              text: 'Tienda',
              onPressed: () {
                widget.game.overlays.remove(MainMenu.id);
                widget.game.overlays.add(StoreMenu.id);
              },
            ),
            const SizedBox(height: 10),

            _MenuButton(
              text: 'Ajustes',
              onPressed: () {
                widget.game.overlays.remove(MainMenu.id);
                widget.game.overlays.add(SettingsMenu.id);
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