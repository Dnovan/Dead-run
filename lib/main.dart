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
              LevelSelectionMenu.id: (_, game) => LevelSelectionMenu(game: game),
              StoreMenu.id: (_, game) => StoreMenu(game),
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