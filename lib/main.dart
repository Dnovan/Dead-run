// lib/main.dart

import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'game/dino_run.dart';
import 'models/player_data.dart';
import 'models/settings.dart';
import 'widgets/game_over_menu.dart';
import 'widgets/hud.dart';
import 'widgets/inventory_menu.dart';
import 'widgets/level_selection_menu.dart';
import 'widgets/main_menu.dart';
import 'widgets/pause_menu.dart';
import 'widgets/settings_menu.dart';
import 'widgets/store_menu.dart';
import 'widgets/story_menu.dart';
import 'widgets/cinematic_screen.dart';
import 'widgets/chapter_complete_menu.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Autenticación anónima para identificar al jugador de forma única.
  try {
    await Supabase.instance.client.auth.signInAnonymously();
    await _ensurePlayerExists();
  } catch (e) {
    debugPrint('Error en autenticación anónima o creación de jugador: $e');
    // Continuamos la ejecución aunque falle la autenticación
    // para que la app no se quede en blanco.
  }

  await initHive();
  runApp(const DinoRunApp());
}

Future<void> initHive() async {
  if (!kIsWeb) {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  }
  Hive.registerAdapter<PlayerData>(PlayerDataAdapter());
  Hive.registerAdapter<Settings>(SettingsAdapter());
}

Future<void> _ensurePlayerExists() async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return;

  try {
    // Intentamos obtener el jugador
    final data = await Supabase.instance.client
        .from('players')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) {
      // Si no existe, lo creamos
      await Supabase.instance.client.from('players').insert({
        'id': user.id,
        'username': 'Guest_${user.id.substring(0, 4)}',
        // Añade otros campos por defecto si son necesarios, e.g. coins
      });
      debugPrint('Jugador creado en Supabase: ${user.id}');
    } else {
      debugPrint('Jugador ya existe en Supabase: ${user.id}');
    }
  } catch (e) {
    debugPrint('Error verificando/creando jugador: $e');
    rethrow; // Para que el catch principal lo capture
  }
}

class DinoRunApp extends StatelessWidget {
  const DinoRunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dead Run', // Nombre del juego
      theme: ThemeData(
        fontFamily: 'Audiowide',
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            fixedSize: const Size(200, 60),
          ),
        ),
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // CAPA 1: FONDO ANIMADO
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: Image.asset(
                'assets/images/fondo_juego.gif',
              ),
            ),
          ),

          // CAPA 2: JUEGO TRANSPARENTE
          GameWidget<DinoRun>.controlled(
            loadingBuilder: (context) => const Center(
              child: SizedBox(width: 200, child: LinearProgressIndicator()),
            ),
            overlayBuilderMap: {
              MainMenu.id: (_, game) => MainMenu(game),
              PauseMenu.id: (_, game) => PauseMenu(game),
              Hud.id: (_, game) => Hud(game),
              GameOverMenu.id: (_, game) => GameOverMenu(game),
              SettingsMenu.id: (_, game) => SettingsMenu(game),
              InventoryMenu.id: (_, game) => InventoryMenu(game: game),
              LevelSelectionMenu.id: (_, game) =>
                  LevelSelectionMenu(game: game),
              StoreMenu.id: (_, game) => StoreMenu(game),
              StoryMenu.id: (_, game) => StoryMenu(game),
              CinematicScreen.id: (_, game) {
                // Aseguramos que haya un capítulo seleccionado
                if (game.currentChapter == null) return const SizedBox();
                return CinematicScreen(
                    game: game, chapter: game.currentChapter!);
              },
              ChapterCompleteMenu.id: (_, game) => ChapterCompleteMenu(game),
            },
            initialActiveOverlays: const [MainMenu.id],
            gameFactory: () => DinoRun(
              camera: CameraComponent.withFixedResolution(
                width: 360,
                height: 180,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
