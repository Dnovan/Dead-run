// lib/widgets/pause_menu.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/game/dino_run.dart';
import '/game/audio_manager.dart';
import '/models/player_data.dart';
import '/widgets/hud.dart';
import '/widgets/main_menu.dart';

class PauseMenu extends StatelessWidget {
  static const id = 'PauseMenu';
  final DinoRun game;

  const PauseMenu(this.game, {super.key});

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
              Selector<PlayerData, int>(
                selector: (_, playerData) => playerData.currentScore,
                builder: (_, score, __) {
                  return Text(
                    'Score: $score',
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
                text: 'Resume',
                onPressed: () {
                  game.overlays.remove(PauseMenu.id);
                  game.overlays.add(Hud.id);
                  game.resumeEngine();
                  AudioManager.instance.resumeBgm();
                },
              ),
              const SizedBox(height: 15),

              _MenuButton(
                text: 'Restart',
                onPressed: () async {
                  game.overlays.remove(PauseMenu.id);
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
                    game.overlays.remove(PauseMenu.id);
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