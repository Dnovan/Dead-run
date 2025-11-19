// lib/widgets/cinematic_screen.dart

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../game/dino_run.dart';
import '../models/chapter_data.dart';
import 'hud.dart';

class CinematicScreen extends StatefulWidget {
  static const String id = 'CinematicScreen';
  final DinoRun game;
  final ChapterData chapter;

  const CinematicScreen({super.key, required this.game, required this.chapter});

  @override
  State<CinematicScreen> createState() => _CinematicScreenState();
}

class _CinematicScreenState extends State<CinematicScreen> {
  int _currentLoreIndex = 0;

  void _handleNext() {
    if (_currentLoreIndex < widget.chapter.lore.length - 1) {
      setState(() {
        _currentLoreIndex++;
      });
    } else {
      // Iniciar el nivel del juego
      widget.game.overlays.remove(CinematicScreen.id);
      widget.game.startGamePlay(widget.chapter.levelId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // FONDO: Imagen ampliada y desenfocada para llenar los bordes negros
          Positioned.fill(
            child: Image.asset(
              widget.chapter.cinematicPath,
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
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: 100.0), // Espacio para el texto
                child: Image.asset(
                  widget.chapter.cinematicPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text(
                        'Imagen de cinemática no encontrada.\nAsegúrate de añadir la imagen en assets/images/cinematics/',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Título del Capítulo
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  widget.chapter.title,
                  style: const TextStyle(
                    fontFamily: 'Audiowide',
                    fontSize: 28, // Reducido un poco para móviles
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                  ),
                ),
              ),
            ),
          ),

          // CONTENEDOR DE LORE Y BOTÓN
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    const Color(0xFF0F0F1A)
                        .withOpacity(0.95), // Dark blue/purple background
                    Colors.transparent,
                  ],
                  stops: const [0.8, 1.0],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Texto del Lore
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A2E)
                              .withOpacity(0.9), // Dark blue panel
                          borderRadius: BorderRadius.circular(
                              8), // Less rounded, more pixel-art feel
                          border: Border.all(
                            color: const Color(0xFF33D1FF), // Neon Cyan border
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF33D1FF).withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Text(
                          widget.chapter.lore[_currentLoreIndex],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Audiowide',
                            fontSize: 16,
                            color: Color(0xFFE0E0E0), // Off-white text
                            height: 1.4,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Botón de Acción
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF1A1A2E), // Dark background
                            foregroundColor:
                                const Color(0xFF33D1FF), // Neon text
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(
                                color: Color(0xFF33D1FF),
                                width: 2,
                              ),
                            ),
                            elevation: 6,
                            shadowColor:
                                const Color(0xFF33D1FF).withOpacity(0.5),
                          ),
                          onPressed: _handleNext,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentLoreIndex <
                                        widget.chapter.lore.length - 1
                                    ? 'SIGUIENTE'
                                    : 'JUGAR',
                                style: const TextStyle(
                                  fontFamily: 'Audiowide',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 5,
                                      color: Color(0xFF33D1FF),
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentLoreIndex <
                                        widget.chapter.lore.length - 1
                                    ? Icons.arrow_forward
                                    : Icons.play_arrow,
                                size: 20,
                                color: const Color(0xFF33D1FF),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
