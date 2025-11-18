// lib/widgets/chapter_complete_menu.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/dino_run.dart';
import '../models/player_data.dart';
import '../models/chapter_data.dart';
import 'main_menu.dart';

class ChapterCompleteMenu extends StatelessWidget {
  static const id = 'ChapterCompleteMenu';
  final DinoRun game;

  const ChapterCompleteMenu(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: game.playerData,
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.8),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'CAPÍTULO COMPLETADO',
                style: TextStyle(
                  fontFamily: 'Audiowide',
                  fontSize: 40,
                  color: Color(0xFF4ECCA3),
                  shadows: [
                    Shadow(
                        blurRadius: 10,
                        color: Colors.black,
                        offset: Offset(2, 2)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Selector<PlayerData, int>(
                selector: (_, playerData) => playerData.currentScore,
                builder: (_, score, __) {
                  return Text(
                    'Puntuación: $score',
                    style: const TextStyle(
                      fontFamily: 'Audiowide',
                      fontSize: 30,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                            blurRadius: 5,
                            color: Colors.black,
                            offset: Offset(1, 1)),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 50),

              // Botón Siguiente Nivel (si existe)
              if (game.currentChapter != null &&
                  game.currentChapter!.id < ChapterData.chapters.length)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextButton(
                    onPressed: () {
                      game.overlays.remove(ChapterCompleteMenu.id);
                      game.startNextChapter();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF4ECCA3),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                    ),
                    child: const Text(
                      'SIGUIENTE NIVEL',
                      style: TextStyle(
                        fontFamily: 'Audiowide',
                        fontSize: 28.0,
                        shadows: [
                          Shadow(
                              blurRadius: 8.0,
                              color: Colors.black,
                              offset: Offset(2, 2)),
                        ],
                      ),
                    ),
                  ),
                ),

              // Botón Volver al Menú
              TextButton(
                onPressed: () {
                  game.overlays.remove(ChapterCompleteMenu.id);
                  game.showMainMenu();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withOpacity(0.9),
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                ),
                child: const Text(
                  'VOLVER AL MENÚ',
                  style: TextStyle(
                    fontFamily: 'Audiowide',
                    fontSize: 28.0,
                    shadows: [
                      Shadow(
                          blurRadius: 8.0,
                          color: Colors.black,
                          offset: Offset(2, 2)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
