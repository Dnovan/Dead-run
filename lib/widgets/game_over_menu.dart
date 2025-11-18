// lib/widgets/game_over_menu.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../game/dino_run.dart';
import '../models/player_data.dart';

class GameOverMenu extends StatefulWidget {
  static const id = 'GameOverMenu';
  final DinoRun game;

  const GameOverMenu(this.game, {super.key});

  @override
  State<GameOverMenu> createState() => _GameOverMenuState();
}

class _GameOverMenuState extends State<GameOverMenu> {
  // ¡¡IMPORTANTE!! Pega aquí el UUID de tu jugador que creaste en Supabase.
  final String _playerId = '5836c3f4-9378-4e31-94c1-78e52482de34';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final score = widget.game.playerData.currentScore;

      widget.game.playerData.coins += score;
      widget.game.playerData.save();

      try {
        await Supabase.instance.client.rpc('update_coins', params: {
          'player_id': _playerId,
          'new_coins': widget.game.playerData.coins,
        });
      } catch (e) {
        debugPrint('Error al guardar monedas en Supabase: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.game.playerData,
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
                    Shadow(
                        blurRadius: 12.0,
                        color: Colors.black,
                        offset: Offset(2, 2))
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
                        Shadow(
                            blurRadius: 8.0,
                            color: Colors.black,
                            offset: Offset(2, 2))
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              Selector<PlayerData, int>(
                selector: (_, playerData) => playerData.currentScore,
                builder: (_, score, __) {
                  return Text(
                    '+ $score Monedas Ganadas',
                    style: const TextStyle(
                      fontFamily: 'Audiowide',
                      fontSize: 24,
                      color: Color(0xFFFFD700),
                      shadows: [
                        Shadow(
                            blurRadius: 8.0,
                            color: Colors.black,
                            offset: Offset(2, 2))
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 50),
              _MenuButton(
                text: 'Restart',
                onPressed: () {
                  widget.game.startGamePlay(widget.game.currentLevel!);
                },
              ),
              const SizedBox(height: 15),
              _MenuButton(
                text: 'Exit',
                onPressed: () {
                  widget.game.showMainMenu();
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
            Shadow(blurRadius: 8.0, color: Colors.black, offset: Offset(2, 2))
          ],
        ),
      ),
    );
  }
}
