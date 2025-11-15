// lib/models/player_data.dart

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'player_data.g.dart';

// Esta clase guarda el progreso del jugador en el dispositivo.
@HiveType(typeId: 0)
class PlayerData extends ChangeNotifier with HiveObjectMixin {
  // Las propiedades existentes no cambian.
  @HiveField(1)
  int highScore = 0;

  // NUEVA PROPIEDAD PARA LAS MONEDAS.
  // La guardamos en el dispositivo. Por defecto empieza en 0.
  @HiveField(2, defaultValue: 0)
  int coins = 0;

  // NUEVA PROPIEDAD PARA LA SKIN EQUIPADA.
  // Guardamos la RUTA al archivo spritesheet de la skin.
  // Por defecto es la skin clásica.
  @HiveField(3, defaultValue: 'DinoSprites - tard.png')
  String equippedSkinAssetPath = 'DinoSprites - tard.png';

  int _lives = 5;
  int get lives => _lives;
  set lives(int value) {
    if (value <= 5 && value >= 0) {
      _lives = value;
      notifyListeners();
    }
  }

  int _currentScore = 0;
  int get currentScore => _currentScore;
  set currentScore(int value) {
    _currentScore = value;

    if (highScore < _currentScore) {
      highScore = _currentScore;
    }
    notifyListeners();
    save(); // Guardar automáticamente cada vez que cambia el score.
  }

  // Nueva función para equipar una skin de forma segura.
  void setEquippedSkin(String newSkinPath) {
    equippedSkinAssetPath = newSkinPath;
    notifyListeners();
    save();
  }
}