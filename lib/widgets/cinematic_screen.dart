// lib/widgets/cinematic_screen.dart

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../game/dino_run.dart';
import '../models/chapter_data.dart';
import 'hud.dart';

class CinematicScreen extends StatelessWidget {
  static const String id = 'CinematicScreen';
  final DinoRun game;
  final ChapterData chapter;

  const CinematicScreen({super.key, required this.game, required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // FONDO: Imagen ampliada y desenfocada para llenar los bordes negros
          Positioned.fill(
            child: Image.asset(
              chapter.cinematicPath,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color:
                    Colors.black.withOpacity(0.5), // Oscurecer un poco el fondo
              ),
            ),
          ),

          // IMAGEN PRINCIPAL: Completa y centrada
          Positioned.fill(
            child: Center(
              child: Image.asset(
                chapter.cinematicPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text(
                      'Imagen de cinemática no encontrada.\nAsegúrate de añadir "cinematica_1.png" en assets/images/cinematics/',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          ),

          // Botón de Continuar
          Positioned(
            bottom: 30,
            right: 30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                side: const BorderSide(color: Colors.white, width: 2),
              ),
              onPressed: () {
                // Iniciar el nivel del juego
                game.overlays.remove(CinematicScreen.id);
                game.startGamePlay(chapter.levelId);
              },
              child: const Text(
                'CONTINUAR',
                style: TextStyle(
                  fontFamily: 'Audiowide',
                  fontSize: 20,
                ),
              ),
            ),
          ),

          // Título del Capítulo (Opcional, para darle contexto)
          Positioned(
            top: 40,
            left: 40,
            child: Text(
              chapter.title,
              style: const TextStyle(
                fontFamily: 'Audiowide',
                fontSize: 32,
                color: Colors.white,
                shadows: [Shadow(blurRadius: 10, color: Colors.black)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
