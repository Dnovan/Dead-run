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
  // Constructor privado
  Dino._(
      Image image,
      Map<DinoAnimationStates, SpriteAnimationData> animationMap,
      this.playerData)
      : super.fromFrameData(image, animationMap);

  // Factory method create
  static Future<Dino> create(
      String skinAssetPath, PlayerData playerData) async {
    print('--- DEBUG DINO CREATE ---');
    print('Original skin path: "$skinAssetPath"');

    // Limpiamos la ruta para Flame.
    // Flame.images.load busca automáticamente en 'assets/images/',
    // así que si la ruta ya incluye eso, lo quitamos para evitar duplicados.
    String cleanPath = skinAssetPath;
    if (cleanPath.startsWith('assets/images/')) {
      cleanPath = cleanPath.replaceFirst('assets/images/', '');
    }

    print('Cleaned skin path for Flame: "$cleanPath"');

    Image image;
    try {
      image = await Flame.images.load(cleanPath);
      print('Skin cargada EXITOSAMENTE: $cleanPath');
    } catch (e) {
      print('FALLO al cargar skin "$cleanPath". Error: $e');
      print('Intentando cargar skin por defecto: DinoSprites - tard.png');
      try {
        image = await Flame.images.load('DinoSprites - tard.png');
        print('Skin por defecto cargada EXITOSAMENTE.');
      } catch (e2) {
        print(
            'ERROR CRÍTICO: No se pudo cargar ni la skin solicitada ni la por defecto. $e2');
        rethrow;
      }
    }

    final animationMap = {
      DinoAnimationStates.idle: SpriteAnimationData.sequenced(
          amount: 4, stepTime: 0.1, textureSize: Vector2.all(24)),
      DinoAnimationStates.run: SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2.all(24),
          texturePosition: Vector2(4 * 24, 0)),
      DinoAnimationStates.kick: SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.1,
          textureSize: Vector2.all(24),
          texturePosition: Vector2(10 * 24, 0)),
      DinoAnimationStates.hit: SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: 0.1,
          textureSize: Vector2.all(24),
          texturePosition: Vector2(14 * 24, 0)),
      DinoAnimationStates.sprint: SpriteAnimationData.sequenced(
          amount: 7,
          stepTime: 0.1,
          textureSize: Vector2.all(24),
          texturePosition: Vector2(17 * 24, 0)),
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
    add(RectangleHitbox.relative(Vector2(0.5, 0.7),
        parentSize: size, position: Vector2(size.x * 0.5, size.y * 0.3) / 2));
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
      if (current != DinoAnimationStates.hit &&
          current != DinoAnimationStates.run) {
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
