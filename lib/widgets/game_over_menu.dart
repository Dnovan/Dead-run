// lib/widgets/game_over_menu.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/game/dino_run.dart';
import '/models/player_data.dart';
import '/widgets/hud.dart';
import '/widgets/main_menu.dart';

class GameOverMenu extends StatelessWidget {
  static const id = 'GameOverMenu';
  final DinoRun game;

  const GameOverMenu(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: game.playerData,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Game Over',
                style: TextStyle(
                  fontFamily: 'Audiowide',
                  fontSize: 60,
                  color: Colors.white,
                  shadows: [
                    Shadow(blurRadius: 12.0, color: Colors.black, offset: Offset(2, 2)),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              Selector<PlayerData, int>(
                selector: (_, playerData) => playerData.currentScore,
                builder: (_, score, __) {
                  return Text(
                    'Your Score: $score',
                    style: const TextStyle(
                      fontFamily: 'Audiowide',
                      fontSize: 40,
                      color: Colors.white,
                      shadows: [
                        Shadow(blurRadius: 8.0, color: Colors.black, offset: Offset(2, 2)),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 50),

              _MenuButton(
                text: 'Restart',
                onPressed: () async {
                  game.overlays.remove(GameOverMenu.id);
                  game.overlays.add(Hud.id);
                  game.resumeEngine();
                  
                  game.playerData.currentScore = 0;
                  game.playerData.lives = 5;
                  await game.startGamePlay(game.currentLevel!);
                },
              ),
              const SizedBox(height: 15),

              _MenuButton(
                text: 'Exit',
                onPressed: () async {
                  game.reset();
                  await Future.delayed(const Duration(milliseconds: 10));
                  
                  if (context.mounted) {
                    game.overlays.remove(GameOverMenu.id);
                    game.overlays.add(MainMenu.id);
                    game.resumeEngine();
                  }
                },
              ),
            ],
          ),
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