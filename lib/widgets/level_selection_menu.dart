// lib/widgets/level_selection_menu.dart

import 'package:flutter/material.dart';
import '../game/dino_run.dart';

// No necesitamos importar 'hud.dart' ni 'main_menu.dart' porque ya no los gestionamos desde aquí.

class _LevelInfo {
  final String levelId;
  final String displayName;
  final String assetPath;

  const _LevelInfo({
    required this.levelId,
    required this.displayName,
    required this.assetPath,
  });
}

class LevelSelectionMenu extends StatefulWidget {
  static const id = 'LevelSelectionMenu';
  final DinoRun game;

  const LevelSelectionMenu({super.key, required this.game});

  @override
  State<LevelSelectionMenu> createState() => _LevelSelectionMenuState();
}

class _LevelSelectionMenuState extends State<LevelSelectionMenu> {
  final List<_LevelInfo> _levels = const [
    _LevelInfo(
      levelId: 'forest',
      displayName: 'El Bosque Eterno',
      assetPath: 'assets/images/background.png',
    ),
    _LevelInfo(
      levelId: 'desert',
      displayName: 'Dunas Olvidadas',
      assetPath: 'assets/images/background_desert.png',
    ),
    _LevelInfo(
      levelId: 'snow',
      displayName: 'Cumbres Gélidas',
      assetPath: 'assets/images/background_nieve.png',
    ),
  ];

  int _selectedIndex = 0;

  void _selectNext() {
    setState(() => _selectedIndex = (_selectedIndex + 1) % _levels.length);
  }

  void _selectPrevious() {
    setState(() => _selectedIndex = (_selectedIndex - 1 + _levels.length) % _levels.length);
  }

  @override
  Widget build(BuildContext context) {
    final selectedLevel = _levels[_selectedIndex];

    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Elige tu Destino',
            style: TextStyle(
              fontFamily: 'Audiowide',
              fontSize: 50,
              color: Colors.white,
              shadows: [Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(2, 2))],
            ),
          ),
          const SizedBox(height: 40),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left, color: Colors.white, size: 50),
                onPressed: _selectPrevious,
              ),
              const SizedBox(width: 20),
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.asset(
                      selectedLevel.assetPath,
                      width: 300,
                      height: 150,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.none,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    selectedLevel.displayName,
                    style: const TextStyle(
                      fontFamily: 'Audiowide',
                      fontSize: 24,
                      color: Colors.white,
                       shadows: [Shadow(blurRadius: 6.0, color: Colors.black, offset: Offset(2, 2))],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.arrow_right, color: Colors.white, size: 50),
                onPressed: _selectNext,
              ),
            ],
          ),
          const SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MenuButton(
                text: 'Jugar',
                onPressed: () {
                  // Simplemente le da la orden al juego de empezar con el nivel seleccionado.
                  widget.game.startGamePlay(selectedLevel.levelId);
                },
              ),
              const SizedBox(width: 40),
              _MenuButton(
                text: 'Volver',
                onPressed: () {
                  // Le da la orden al juego de volver al menú principal.
                  widget.game.showMainMenu();
                },
              ),
            ],
          ),
        ],
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
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        overlayColor: Colors.white.withAlpha((255 * 0.1).round()),
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