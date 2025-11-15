// lib/models/skin.dart

import 'package:flame/components.dart';
import 'package:hive/hive.dart';


// Enum for the different skins available.
@HiveType(typeId: 2)
enum Skin {
  @HiveField(0)
  normal,
  @HiveField(1)
  fire,
  @HiveField(2)
  toxic,
  @HiveField(3)
  chad,
}

// A class that holds all the data for a given skin.
class SkinData {
  final String assetPath;
  final Map<DinoAnimationStates, SpriteAnimationData> animationData;

  const SkinData({
    required this.assetPath,
    required this.animationData,
  });

  // A map that holds the data for all the skins.
  static final Map<Skin, SkinData> skinList = {
    Skin.normal: SkinData(
      assetPath: 'DinoSprites - tard.png',
      animationData: {
        DinoAnimationStates.idle: SpriteAnimationData.sequenced(amount: 4, stepTime: 0.1, textureSize: Vector2.all(24)),
        DinoAnimationStates.run: SpriteAnimationData.sequenced(amount: 6, stepTime: 0.1, textureSize: Vector2.all(24), texturePosition: Vector2(4 * 24, 0)),
        DinoAnimationStates.kick: SpriteAnimationData.sequenced(amount: 4, stepTime: 0.1, textureSize: Vector2.all(24), texturePosition: Vector2(10 * 24, 0)),
        DinoAnimationStates.hit: SpriteAnimationData.sequenced(amount: 3, stepTime: 0.1, textureSize: Vector2.all(24), texturePosition: Vector2(14 * 24, 0)),
        DinoAnimationStates.sprint: SpriteAnimationData.sequenced(amount: 7, stepTime: 0.1, textureSize: Vector2.all(24), texturePosition: Vector2(17 * 24, 0)),
      },
    ),
    Skin.fire: SkinData(
      assetPath: 'Rino/dino_fuego.png',
      animationData: {
        DinoAnimationStates.idle: SpriteAnimationData.sequenced(amount: 4, stepTime: 0.1, textureSize: Vector2.all(24)),
        DinoAnimationStates.run: SpriteAnimationData.sequenced(amount: 6, stepTime: 0.1, textureSize: Vector2.all(24), texturePosition: Vector2(4 * 24, 0)),
        DinoAnimationStates.kick: SpriteAnimationData.sequenced(amount: 4, stepTime: 0.1, textureSize: Vector2.all(24), texturePosition: Vector2(10 * 24, 0)),
        DinoAnimationStates.hit: SpriteAnimationData.sequenced(amount: 3, stepTime: 0.1, textureSize: Vector2.all(24), texturePosition: Vector2(14 * 24, 0)),
        DinoAnimationStates.sprint: SpriteAnimationData.sequenced(amount: 7, stepTime: 0.1, textureSize: Vector2.all(24), texturePosition: Vector2(17 * 24, 0)),
      },
    ),
    Skin.toxic: SkinData(
      assetPath: 'Rino/dino_toxico.png',
      animationData: {
        DinoAnimationStates.idle: SpriteAnimationData.sequenced(amount: 4, stepTime: 0.1, textureSize: Vector2.all(24)),
        DinoAnimationStates.run: SpriteAnimationData.sequenced(amount: 6, stepTime: 0.1, textureSize: Vector2.all(24), texturePosition: Vector2(4 * 24, 0)),
        DinoAnimationStates.kick: SpriteAnimationData.sequenced(amount: 4, stepTime: 0.1, textureSize: Vector2.all(24), texturePosition: Vector2(10 * 24, 0)),
        DinoAnimationStates.hit: SpriteAnimationData.sequenced(amount: 3, stepTime: 0.1, textureSize: Vector2.all(24), texturePosition: Vector2(14 * 24, 0)),
        DinoAnimationStates.sprint: SpriteAnimationData.sequenced(amount: 7, stepTime: 0.1, textureSize: Vector2.all(24), texturePosition: Vector2(17 * 24, 0)),
      },
    ),
    Skin.chad: SkinData(
      assetPath: 'Rino/dino_chad.png',
      animationData: {
        DinoAnimationStates.idle: SpriteAnimationData.sequenced(amount: 4, stepTime: 0.1, textureSize: Vector2.all(24)),
        DinoAnimationStates.run: SpriteAnimationData.sequenced(amount: 6, stepTime: 0.1, textureSize: Vector2.all(24), texturePosition: Vector2(4 * 24, 0)),
        DinoAnimationStates.kick: SpriteAnimationData.sequenced(amount: 4, stepTime: 0.1, textureSize: Vector2.all(24), texturePosition: Vector2(10 * 24, 0)),
        DinoAnimationStates.hit: SpriteAnimationData.sequenced(amount: 3, stepTime: 0.1, textureSize: Vector2.all(24), texturePosition: Vector2(14 * 24, 0)),
        DinoAnimationStates.sprint: SpriteAnimationData.sequenced(amount: 7, stepTime: 0.1, textureSize: Vector2.all(24), texturePosition: Vector2(17 * 24, 0)),
      },
    ),
  };
}

// Enum for the dino animation states.
enum DinoAnimationStates {
  idle,
  run,
  kick,
  hit,
  sprint,
}
