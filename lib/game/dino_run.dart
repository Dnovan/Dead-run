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
import 'audio_manager.dart';
import 'dino.dart';
import 'enemy_manager.dart';
import '../models/player_data.dart';
import '../models/settings.dart';
import '../widgets/game_over_menu.dart';
import '../widgets/hud.dart';
import '../widgets/pause_menu.dart';
import '../widgets/main_menu.dart';
import '../widgets/level_selection_menu.dart';
import '../models/chapter_data.dart';
import '../widgets/cinematic_screen.dart';
import '../widgets/chapter_complete_menu.dart';

class DinoRun extends FlameGame with TapDetector, HasCollisionDetection {
  DinoRun({super.camera});

  static const _audioAssets = [
    '8BitPlatformerLoop.wav',
    'Desert_song.mp3',
    'Montañas_song.mp3',
    'Praderas_song.mp3',
    'cave_song.mp3',
    'hurt7.wav',
    'jump14.wav',
  ];

  static const _imageAssets = [
    'fondo_juego.gif',
    'DinoSprites - tard.png',
    'Rino/dino_fuego.png',
    'Rino/dino_toxico.png',
    'Rino/dino_chad.png',
    'AngryPig/Walk (36x30).png',
    'Bat/Flying (46x30).png',
    'Rino/Run (52x34).png',
    'parallax/plx-1.png',
    'parallax/plx-2.png',
    'parallax/plx-3.png',
    'parallax/plx-4.png',
    'parallax/plx-5.png',
    'parallax/plx-6.png',
    'Desert/desert_background.png',
    'Desert/desert_midground_far.png',
    'Desert/desert_midground_near.png',
    'Desert/desert_foreground_far.png',
    'Desert/desert_foreground_near.png',
    'Desert/desert_ground.png',
    'Montañas/1.png',
    'Montañas/2.png',
    'Montañas/3.png',
    'Praderas/1.png',
    'Praderas/2.png',
    'Praderas/3.png',
    'Praderas/4.png',
    'Praderas/5.png',
    'Praderas/6.png',
    'Cuevacristal/plan_1.png',
    'Cuevacristal/plan_2.png',
    'Cuevacristal/plan_3.png',
    'Cuevacristal/plan_4.png',
    'Cuevacristal/plan_5.png',
    'Cuevacristal/plan_6.png',
    'background_praderas.png',
    'background_cueva.png',
    'cinematics/cinematic_4.png',
    'cinematics/cinematic_5.png',
  ];

  late Dino _dino;
  late Settings settings;
  late PlayerData playerData;
  late EnemyManager _enemyManager;
  ParallaxComponent? parallaxBackground;
  RectangleComponent? _levelBackground; // Volvemos a necesitar la cortina negra
  String? currentLevel;
  ChapterData? currentChapter;

  Vector2 get virtualSize => camera.viewport.virtualSize;

  @override
  Color backgroundColor() {
    // Si estamos en un nivel, fondo negro opaco para tapar el GIF del menú.
    // Si estamos en el menú (currentLevel == null), transparente para ver el GIF.
    if (currentLevel != null) {
      return const Color(0xFF000000);
    }
    return Colors.transparent;
  }

  @override
  Future<void> onLoad() async {
    await Flame.device.fullScreen();
    await Flame.device.setLandscape();
    playerData = await _readPlayerData();
    settings = await _readSettings();
    await AudioManager.instance.init(_audioAssets, settings);
    await images.loadAll(_imageAssets);
    camera.viewfinder.position = virtualSize * 0.5;

    showMainMenu();
  }

  Future<void> _loadParallaxBackground(LevelData levelData) async {
    parallaxBackground?.removeFromParent();

    // VERSIÓN COMPATIBLE: Creamos el parallax sin el parámetro 'fill'.
    final parallaxImages = <ParallaxImageData>[];
    for (final imageName in levelData.imageNames) {
      parallaxImages.add(ParallaxImageData('${levelData.folder}/$imageName'));
    }

    parallaxBackground = await loadParallaxComponent(
      parallaxImages,
      baseVelocity: Vector2(levelData.speed, 0),
      velocityMultiplierDelta: Vector2(1.4, 0),
    );
    parallaxBackground?.priority =
        -10; // Prioridad para que esté detrás de los personajes.

    world.add(parallaxBackground!);
  }

  // --- MÉTODOS DE GESTIÓN DE ESTADO ---

  void showMainMenu() {
    overlays.clear();
    cleanUpLevel();
    overlays.add(MainMenu.id);
    AudioManager.instance.startBgm('8BitPlatformerLoop.wav');
    resumeEngine();
  }

  void showLevelSelection() {
    currentChapter = null; // Aseguramos que no estamos en modo historia
    overlays.clear();
    overlays.add(LevelSelectionMenu.id);
  }

  void startChapter(ChapterData chapter) {
    overlays.clear();
    // Pasamos el capítulo al overlay de cinemática.
    // Como el overlay se construye en main.dart, necesitamos una forma de pasarle datos.
    // Una opción es tener una variable 'currentChapter' en DinoRun.
    currentChapter = chapter;
    overlays.add(CinematicScreen.id);
  }

  Future<void> startStoryLevel(ChapterData chapter) async {
    // Iniciamos el nivel asociado al capítulo
    await startGamePlay(chapter.levelId);
    // Aquí podríamos añadir lógica extra para el modo historia,
    // como objetivos específicos o límites de tiempo.
  }

  void startNextChapter() {
    if (currentChapter == null) return;

    // Buscar el siguiente capítulo por ID
    final nextChapterId = currentChapter!.id + 1;
    try {
      final nextChapter =
          ChapterData.chapters.firstWhere((c) => c.id == nextChapterId);
      startChapter(nextChapter);
    } catch (e) {
      // No hay más capítulos
      print("No hay más capítulos disponibles.");
      showMainMenu();
    }
  }

  Future<void> startGamePlay(String levelId) async {
    // Limpiamos el nivel anterior (fondos, actores, etc.) para evitar duplicados.
    cleanUpLevel();

    overlays.clear();
    reset(); // Reinicia puntuación y vidas.

    final levelData = LevelData.levels[levelId];
    if (levelData == null) {
      return;
    }

    currentLevel = levelId;

    // AÑADIMOS LA CORTINA NEGRA para tapar el fondo global del GIF.
    _levelBackground = RectangleComponent(
      size: virtualSize,
      paint: Paint()..color = const Color(0xFF000000), // Color negro
      priority:
          -11, // Prioridad aún más baja que el parallax para estar detrás de todo.
    );
    world.add(_levelBackground!);

    await _loadParallaxBackground(levelData);
    // AudioManager.instance.startBgm(levelData.song); // MOVED: To end of method

    // Recargamos los datos del jugador para asegurar que la skin esté actualizada.
    playerData = await _readPlayerData();

    _dino = await Dino.create(
        playerData.equippedSkinAssetPath, playerData, levelData.speed);
    _enemyManager = EnemyManager();

    world.add(_dino);
    world.add(_enemyManager);

    overlays.add(Hud.id);
    AudioManager.instance.startBgm(
        levelData.song); // MOVED HERE: Start music only when game is ready
    resumeEngine();
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

  void cleanUpLevel() {
    AudioManager.instance.stopBgm(); // ADDED: Stop any playing music
    _disconnectActors();
    parallaxBackground?.removeFromParent();
    parallaxBackground = null;

    // Quitamos la cortina negra al volver al menú.
    _levelBackground?.removeFromParent();
    _levelBackground = null;

    currentLevel = null;
  }

  void reset() {
    playerData.currentScore = 0;
    playerData.lives = 5;
    _disconnectActors();
  }

  void onGameOver() {
    pauseEngine();
    overlays.clear();
    overlays.add(GameOverMenu.id);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (playerData.lives <= 0 && overlays.isActive(Hud.id)) {
      onGameOver();
    }

    // Lógica de victoria para el Modo Historia
    if (currentChapter != null && overlays.isActive(Hud.id)) {
      if (playerData.currentScore >= currentChapter!.targetScore) {
        pauseEngine();

        // Guardar progreso: Desbloquear el siguiente capítulo
        // Si completamos el capítulo 1, desbloqueamos el 2 (highestCompletedChapter = 1).
        playerData.completeChapter(currentChapter!.id);

        overlays.remove(Hud.id);
        overlays.add(ChapterCompleteMenu.id);
      }
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (overlays.isActive(Hud.id)) {
      _dino.jump();
    }
    super.onTapDown(info);
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
    if (data == null)
      await box.put('DinoRun.Settings', Settings(bgm: true, sfx: true));
    return box.get('DinoRun.Settings')!;
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    super.lifecycleStateChange(state);
    switch (state) {
      case AppLifecycleState.resumed:
        if (overlays.isActive(Hud.id)) {
          resumeEngine();
          AudioManager.instance.resumeBgm();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        if (overlays.isActive(Hud.id)) {
          pauseEngine();
          AudioManager.instance.pauseBgm();
          overlays.remove(Hud.id);
          overlays.add(PauseMenu.id);
        }
        break;
    }
  }
}
