// lib/game/dino.dart

import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import 'enemy.dart';
import 'dino_run.dart';
import 'audio_manager.dart';
import '../models/player_data.dart';

enum DinoAnimationStates { idle, run, kick, hit, sprint }

class Dino extends SpriteAnimationGroupComponent<DinoAnimationStates>
    with CollisionCallbacks, HasGameReference<DinoRun> {

  // El constructor ahora es privado. Nadie puede crear un Dino directamente.
  Dino._(Image image, Map<DinoAnimationStates, SpriteAnimationData> animationMap, this.playerData)
      : super.fromFrameData(image, animationMap);

  // ¡LA MAGIA! Un método "fábrica" que construye el Dino correcto.
  static Future<Dino> create(String skinAssetPath, PlayerData playerData) async {
    final image = await Flame.images.load(skinAssetPath);
    
    // Aquí definimos las animaciones para cada skin.
    // Por ahora, asumimos que todas son recolors y tienen el mismo layout.
    // Si tuvieras una skin con animaciones diferentes, solo tendrías que cambiarlo aquí.
    final animationMap = {
      DinoAnimationStates.idle: SpriteAnimationData.sequenced(amount: 4, stepTime: 0.1, textureSize: Vector2.all(24)),
      DinoAnimationStates.run: SpriteAnimationData.sequenced(amount: 6, stepTime: 0.1, textureSize: Vector2.all(24), texturePosition: Vector2(4 * 24, 0)),
      DinoAnimationStates.kick: SpriteAnimationData.sequenced(amount: 4, stepTime: 0.1, textureSize: Vector2.all(24), texturePosition: Vector2(10 * 24, 0)),
      DinoAnimationStates.hit: SpriteAnimationData.sequenced(amount: 3, stepTime: 0.1, textureSize: Vector2.all(24), texturePosition: Vector2(14 * 24, 0)),
      DinoAnimationStates.sprint: SpriteAnimationData.sequenced(amount: 7, stepTime: 0.1, textureSize: Vector2.all(24), texturePosition: Vector2(17 * 24, 0)),
    };

    return Dino._(image, animationMap, playerData);
  }

  double yMax = 0.0;
  double speedY = 0.0;
  final Timer _hitTimer = Timer(1);
  static const double gravity = 800;
  final PlayerData playerData;
  bool isHit = false;

  @override
  void onMount() {
    _reset();
    add(RectangleHitbox.relative(
      Vector2(0.5, 0.7), parentSize: size, position: Vector2(size.x * 0.5, size.y * 0.3) / 2
    ));
    yMax = y;
    _hitTimer.onTick = () {
      current = DinoAnimationStates.run;
      isHit = false;
    };
    super.onMount();
  }

  @override
  void update(double dt) {
    speedY += gravity * dt;
    y += speedY * dt;
    if (isOnGround) {
      y = yMax;
      speedY = 0.0;
      if (current != DinoAnimationStates.hit && current != DinoAnimationStates.run) {
        current = DinoAnimationStates.run;
      }
    }
    _hitTimer.update(dt);
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if ((other is Enemy) && (!isHit)) {
      hit();
    }
  }

  bool get isOnGround => (y >= yMax);

  void jump() {
    if (isOnGround) {
      speedY = -300;
      current = DinoAnimationStates.idle;
      AudioManager.instance.playSfx('jump14.wav');
    }
  }

  void hit() {
    isHit = true;
    AudioManager.instance.playSfx('hurt7.wav');
    current = DinoAnimationStates.hit;
    _hitTimer.start();
    playerData.lives -= 1;
  }

  void _reset() {
    anchor = Anchor.bottomLeft;
    position = Vector2(32, game.virtualSize.y - 22);
    size = Vector2.all(24);
    current = DinoAnimationStates.run;
    isHit = false;
    speedY = 0.0;
  }
}