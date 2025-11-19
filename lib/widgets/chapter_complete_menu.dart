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
        backgroundColor:
            Colors.transparent, // Usaremos un Container con gradiente
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0F0F1A), // Dark blue/black
                Color(0xFF1A1A2E), // Deep purple/blue
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'CAPÍTULO COMPLETADO',
                  style: TextStyle(
                    fontFamily: 'Audiowide',
                    fontSize: 40,
                    color: Color(0xFF33D1FF), // Neon Cyan
                    shadows: [
                      Shadow(
                          blurRadius: 15,
                          color: Color(0xFF33D1FF), // Cyan Glow
                          offset: Offset(0, 0)),
                      Shadow(
                          blurRadius: 5,
                          color: Colors.black,
                          offset: Offset(2, 2)),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Selector<PlayerData, int>(
                  selector: (_, playerData) => playerData.currentScore,
                  builder: (_, score, __) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFF33D1FF).withOpacity(0.5)),
                      ),
                      child: Text(
                        'Puntuación: $score',
                        style: const TextStyle(
                          fontFamily: 'Audiowide',
                          fontSize: 30,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                                blurRadius: 5,
                                color: Color(0xFF33D1FF),
                                offset: Offset(0, 0)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 60),

                // Botón Siguiente Nivel (si existe)
                if (game.currentChapter != null &&
                    game.currentChapter!.id < ChapterData.chapters.length)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _buildNeonButton(
                      text: 'SIGUIENTE NIVEL',
                      onPressed: () {
                        game.overlays.remove(ChapterCompleteMenu.id);
                        game.startNextChapter();
                      },
                      isPrimary: true,
                    ),
                  ),

                // Botón Volver al Menú
                _buildNeonButton(
                  text: 'VOLVER AL MENÚ',
                  onPressed: () {
                    game.overlays.remove(ChapterCompleteMenu.id);
                    game.showMainMenu();
                  },
                  isPrimary: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNeonButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    final color =
        isPrimary ? const Color(0xFF33D1FF) : Colors.white.withOpacity(0.8);
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xFF1A1A2E),
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: color.withOpacity(isPrimary ? 1.0 : 0.5),
            width: 2,
          ),
        ),
        elevation: isPrimary ? 8 : 0,
        shadowColor: color.withOpacity(0.4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Audiowide',
          fontSize: 24.0,
          color: color,
          shadows: isPrimary
              ? [
                  Shadow(
                      blurRadius: 8.0,
                      color: color,
                      offset: const Offset(0, 0)),
                ]
              : [],
        ),
      ),
    );
  }
}
