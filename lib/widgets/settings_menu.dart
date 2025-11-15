// lib/widgets/settings_menu.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/dino_run.dart';
import '../models/settings.dart';
import 'main_menu.dart';
import '../game/audio_manager.dart';

// Represents the settings menu overlay.
class SettingsMenu extends StatelessWidget {
  static const id = 'SettingsMenu';
  final DinoRun game;

  const SettingsMenu(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    // Envolvemos todo en el Provider como antes, pero la UI es completamente nueva.
    return ChangeNotifierProvider.value(
      value: game.settings,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600), // Ancho más ajustado para este menú
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: const Color(0xCC0A1724), // El mismo azul oscuro semi-transparente de la tienda
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withAlpha((255 * 0.2).round())),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha((255 * 0.5).round()), blurRadius: 15, spreadRadius: 5),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // La columna solo ocupa el espacio que necesita.
              children: [
                // Título "Ajustes" con el estilo del juego.
                const Text(
                  'Ajustes',
                  style: TextStyle(
                    fontFamily: 'Audiowide',
                    fontSize: 50,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(2, 2))],
                  ),
                ),
                const Divider(color: Colors.white30, thickness: 2, height: 40),

                // Fila para el ajuste de Música
                Selector<Settings, bool>(
                  selector: (_, settings) => settings.bgm,
                  builder: (context, bgm, __) {
                    return _SettingsRow(
                      label: 'Música',
                      value: bgm,
                      onChanged: (bool value) {
                        Provider.of<Settings>(context, listen: false).bgm = value;
                        if (value) {
                          AudioManager.instance.startBgm('8BitPlatformerLoop.wav');
                        } else {
                          AudioManager.instance.stopBgm();
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Fila para el ajuste de Efectos
                Selector<Settings, bool>(
                  selector: (_, settings) => settings.sfx,
                  builder: (context, sfx, __) {
                    return _SettingsRow(
                      label: 'Efectos',
                      value: sfx,
                      onChanged: (bool value) {
                        Provider.of<Settings>(context, listen: false).sfx = value;
                      },
                    );
                  },
                ),
                const Divider(color: Colors.white30, thickness: 2, height: 40),
                
                // Botón "Volver" con el estilo de los otros menús.
                _MenuButton(
                  text: 'Volver',
                  onPressed: () {
                    game.overlays.remove(SettingsMenu.id);
                    game.overlays.add(MainMenu.id);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget auxiliar para las filas de ajustes. Mantiene el código limpio.
class _SettingsRow extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool) onChanged;

  const _SettingsRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Audiowide',
              fontSize: 28,
              color: Colors.white,
              shadows: [Shadow(blurRadius: 4.0, color: Colors.black)],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF33D1FF).withAlpha((255 * 0.5).round()),
            activeThumbColor: const Color(0xFF33D1FF),
            inactiveTrackColor: Colors.grey.withAlpha((255 * 0.5).round()),
            inactiveThumbColor: Colors.grey,
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar del menú principal para consistencia.
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
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
        overlayColor: Colors.white.withAlpha((255 * 0.1).round()),
      ),
      child: Text(text, style: const TextStyle(fontFamily: 'Audiowide', fontSize: 28.0, shadows: [Shadow(blurRadius: 8.0, color: Colors.black, offset: Offset(2, 2))])),
    );
  }
}