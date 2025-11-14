// lib/game/dino_run.dart

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/level_data.dart';
import '/game/audio_manager.dart';
import '/game/dino.dart';
import '/game/enemy_manager.dart';
import '/models/player_data.dart';
import '/models/settings.dart';
import '/widgets/game_over_menu.dart';
import '/widgets/hud.dart';
import '/widgets/pause_menu.dart';

class DinoRun extends FlameGame with TapDetector, HasCollisionDetection {
  DinoRun({super.camera});

  static const _audioAssets = [
    '8BitPlatformerLoop.wav', 'Desert_song.mp3', 'Montañas_song.mp3',
    'hurt7.wav', 'jump14.wav',
  ];

  static const _imageAssets = [
      'fondo_juego.gif', 'DinoSprites - tard.png', 'AngryPig/Walk (36x30).png',
      'Bat/Flying (46x30).png', 'Rino/Run (52x34).png', 'parallax/plx-1.png',
      'parallax/plx-2.png', 'parallax/plx-3.png', 'parallax/plx-4.png', 'parallax/plx-5.png',
      'parallax/plx-6.png', 'Desert/desert_background.png', 'Desert/desert_midground_far.png',
      'Desert/desert_midground_near.png', 'Desert/desert_foreground_far.png',
      'Desert/desert_foreground_near.png', 'Desert/desert_ground.png',
      'Montañas/1.png', 'Montañas/2.png', 'Montañas/3.png',
  ];
  
  late Dino _dino;
  late Settings settings;
  late PlayerData playerData;
  late EnemyManager _enemyManager;
  ParallaxComponent? parallaxBackground;
  RectangleComponent? _levelBackground;
  String? currentLevel;

  Vector2 get virtualSize => camera.viewport.virtualSize;
  
  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await Flame.device.fullScreen();
    await Flame.device.setLandscape();

    playerData = await _readPlayerData();
    settings = await _readSettings();

    await AudioManager.instance.init(_audioAssets, settings);
    await images.loadAll(_imageAssets);
    
    camera.viewfinder.position = virtualSize * 0.5;
  }
      
  Future<void> _loadParallaxBackground(LevelData levelData) async {
    parallaxBackground?.removeFromParent();
    
    final parallaxImages = <ParallaxImageData>[];
    for (final imageName in levelData.imageNames) {
      parallaxImages.add(ParallaxImageData('${levelData.folder}/$imageName'));
    }
    
    parallaxBackground = await loadParallaxComponent(
      parallaxImages,
      baseVelocity: Vector2(10, 0),
      velocityMultiplierDelta: Vector2(1.4, 0),
    );
    parallaxBackground?.priority = 0;
    world.add(parallaxBackground!); 
  }
      
  Future<void> startGamePlay(String levelId) async {
    final levelData = LevelData.levels[levelId];
    if (levelData == null) { return; }
    
    currentLevel = levelId;

    _levelBackground = RectangleComponent(
      size: virtualSize,
      paint: Paint()..color = const Color(0xFF000000),
      priority: -1,
    );
    world.add(_levelBackground!);
    
    await _loadParallaxBackground(levelData);
    AudioManager.instance.startBgm(levelData.song);
    
    _dino = Dino(images.fromCache('DinoSprites - tard.png'), playerData);
    _enemyManager = EnemyManager();

    world.add(_dino);
    world.add(_enemyManager);
  }
      
  void _disconnectActors() {
    final dino = world.children.whereType<Dino>().firstOrNull;
    if (dino != null) dino.removeFromParent();

    final enemyManager = world.children.whereType<EnemyManager>().firstOrNull;
    if (enemyManager != null) {
      enemyManager.removeAllEnemies();
      enemyManager.removeFromParent();
    }
  }
      
  void reset() {
    _levelBackground?.removeFromParent();
    _levelBackground = null;
    
    _disconnectActors();
    parallaxBackground?.removeFromParent();
    parallaxBackground = null;
    
    playerData.currentScore = 0;
    playerData.lives = 5;
    currentLevel = null;
    
    AudioManager.instance.startBgm('8BitPlatformerLoop.wav');
  }

  @override
  void update(double dt) {
    if (playerData.lives <= 0 && overlays.isActive(Hud.id)) {
      overlays.add(GameOverMenu.id);
      overlays.remove(Hud.id);
      pauseEngine();
      AudioManager.instance.pauseBgm();
    }
    super.update(dt);
  }

  // ¡¡AQUÍ ESTÁ LA CORRECCIÓN FINAL!!
  @override
  void onTapDown(TapDownInfo event)
   {
    if (overlays.isActive(Hud.id)) {
      _dino.jump();
    }
    super.onTapDown(event);
  }

  Future<PlayerData> _readPlayerData() async {
    final box = await Hive.openBox<PlayerData>('DinoRun.PlayerDataBox');
    final data = box.get('DinoRun.PlayerData');
    if (data == null) await box.put('DinoRun.PlayerData', PlayerData());
    return box.get('DinoRun.PlayerData')!;
  }

  Future<Settings> _readSettings() async {
    final box = await Hive.openBox<Settings>('DinoRun.SettingsBox');
    final data = box.get('DinoRun.Settings');
    if (data == null) await box.put('DinoRun.Settings', Settings(bgm: true, sfx: true));
    return box.get('DinoRun.Settings')!;
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!(overlays.isActive(PauseMenu.id)) && !(overlays.isActive(GameOverMenu.id))) {
          resumeEngine();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        if (overlays.isActive(Hud.id)) {
          overlays.remove(Hud.id);
          overlays.add(PauseMenu.id);
        }
        pauseEngine();
        break;
    }
    super.lifecycleStateChange(state);
  }
}