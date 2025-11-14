// lib/widgets/level_selection_menu.dart

import 'package:flutter/material.dart';
import '../../game/dino_run.dart';
import 'main_menu.dart';
import 'hud.dart';

// Clase para organizar los datos de cada nivel.
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
  // Catálogo de niveles.
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
    setState(() {
      _selectedIndex = (_selectedIndex + 1) % _levels.length;
    });
  }

  void _selectPrevious() {
    setState(() {
      _selectedIndex = (_selectedIndex - 1 + _levels.length) % _levels.length;
    });
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

          // --- El Carrusel Interactivo (sin cambios aquí) ---
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

          // ¡¡AQUÍ ESTÁ LA MAGIA!! Reemplazamos los ElevatedButton
          // por nuestros botones personalizados estilo Dead Cells.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MenuButton(
                text: 'Jugar',
                onPressed: () async {
                  await widget.game.startGamePlay(selectedLevel.levelId);
                  widget.game.overlays.remove(LevelSelectionMenu.id);
                  widget.game.overlays.add(Hud.id);
                },
              ),
              const SizedBox(width: 40),
              _MenuButton(
                text: 'Volver',
                onPressed: () {
                  widget.game.overlays.remove(LevelSelectionMenu.id);
                  widget.game.overlays.add(MainMenu.id);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar para crear botones de texto con el estilo "GOD"
// y mantener consistencia con los otros menús.
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