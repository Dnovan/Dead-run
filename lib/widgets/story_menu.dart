// lib/widgets/story_menu.dart

import 'package:flutter/material.dart';
import '../game/dino_run.dart';
import '../models/chapter_data.dart';
import 'main_menu.dart';
import 'cinematic_screen.dart';

class StoryMenu extends StatelessWidget {
  static const String id = 'StoryMenu';
  final DinoRun game;

  const StoryMenu(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF4ECCA3), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4ECCA3).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'MODO HISTORIA',
                style: TextStyle(
                  fontFamily: 'Audiowide',
                  fontSize: 40,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 10, color: Color(0xFF4ECCA3))],
                ),
              ),
              const SizedBox(height: 30),

              // Lista de Capítulos
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: ChapterData.chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = ChapterData.chapters[index];
                    // Lógica de desbloqueo:
                    // El capítulo 1 (index 0) siempre está desbloqueado.
                    // El capítulo 2 (index 1) se desbloquea si highestCompletedChapter >= 1.
                    // En general: desbloqueado si (chapter.id - 1) <= highestCompletedChapter.
                    final isLocked = (chapter.id - 1) >
                        game.playerData.highestCompletedChapter;

                    return _ChapterCard(
                      chapter: chapter,
                      isLocked: isLocked,
                      onTap: isLocked
                          ? null
                          : () {
                              game.overlays.remove(StoryMenu.id);
                              game.startChapter(chapter);
                            },
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              // Botón Volver
              TextButton(
                onPressed: () {
                  game.overlays.remove(StoryMenu.id);
                  game.overlays.add(MainMenu.id);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back),
                    SizedBox(width: 10),
                    Text(
                      'Volver al Menú',
                      style: TextStyle(fontFamily: 'Audiowide', fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final ChapterData chapter;
  final VoidCallback? onTap; // Puede ser null si está bloqueado
  final bool isLocked;

  const _ChapterCard({
    required this.chapter,
    required this.onTap,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isLocked ? const Color(0xFF0F1520) : const Color(0xFF16213E),
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: isLocked
              ? Colors.grey.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isLocked
                      ? const Color(0xFF1A1A1A)
                      : const Color(0xFF0F3460),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: isLocked
                      ? const Icon(Icons.lock, color: Colors.grey, size: 30)
                      : Text(
                          '${chapter.id}',
                          style: const TextStyle(
                            fontFamily: 'Audiowide',
                            fontSize: 30,
                            color: Color(0xFF4ECCA3),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapter.title,
                      style: TextStyle(
                        fontFamily: 'Audiowide',
                        fontSize: 20,
                        color: isLocked ? Colors.grey : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      isLocked
                          ? "Completa el capítulo anterior"
                          : chapter.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isLocked
                            ? Colors.grey.withOpacity(0.5)
                            : Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLocked)
                const Icon(Icons.play_circle_fill,
                    color: Color(0xFF4ECCA3), size: 40),
            ],
          ),
        ),
      ),
    );
  }
}
