// lib/widgets/hud.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/dino_run.dart';
import '../game/audio_manager.dart';
import '../models/player_data.dart';
import 'pause_menu.dart';

class Hud extends StatelessWidget {
  static const id = 'Hud';
  final DinoRun game;

  const Hud(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: game.playerData,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Selector<PlayerData, int>(
                      selector: (_, playerData) => playerData.currentScore,
                      builder: (_, score, __) => Text('Score: $score',
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontFamily: 'Audiowide')),
                    ),
                    Selector<PlayerData, int>(
                      selector: (_, playerData) => playerData.highScore,
                      builder: (_, highScore, __) => Text('High: $highScore',
                          style: const TextStyle(
                              color: Colors.white, fontFamily: 'Audiowide')),
                    ),
                  ],
                ),
                Selector<PlayerData, int>(
                  selector: (_, playerData) => playerData.coins,
                  builder: (_, coins, __) {
                    return Row(
                      children: [
                        const Icon(Icons.monetization_on,
                            color: Color(0xFFFFD700), size: 24),
                        const SizedBox(width: 5),
                        Text('$coins',
                            style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontFamily: 'Audiowide')),
                      ],
                    );
                  },
                ),
                TextButton(
                  onPressed: () {
                    game.overlays.remove(Hud.id);
                    game.overlays.add(PauseMenu.id);
                    game.pauseEngine();
                    AudioManager.instance.pauseBgm();
                  },
                  child: const Icon(Icons.pause, color: Colors.white, size: 30),
                ),
                Selector<PlayerData, int>(
                  selector: (_, playerData) => playerData.lives,
                  builder: (_, lives, __) {
                    return Row(
                      children: List.generate(
                          5,
                          (index) => Icon(
                                index < lives
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                              )),
                    );
                  },
                ),
              ],
            ),
          ),
          _buildProgressBar(context),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    if (game.currentChapter == null) return const SizedBox.shrink();

    return Positioned(
      top: 60,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 300,
          height: 20,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(10),
            color: Colors.black.withOpacity(0.5),
          ),
          child: Selector<PlayerData, int>(
            selector: (_, playerData) => playerData.currentScore,
            builder: (_, score, __) {
              final progress =
                  (score / game.currentChapter!.targetScore).clamp(0.0, 1.0);
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.transparent,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF4ECCA3)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
