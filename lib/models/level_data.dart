// lib/models/level_data.dart

class LevelData {
  final List<String> imageNames;
  final String folder;
  final String song;
  final double speed; // ¡NUEVA PROPIEDAD PARA LA VELOCIDAD!

  const LevelData({
    required this.imageNames,
    required this.folder,
    required this.song,
    required this.speed, // Se añade al constructor
  });

  static final Map<String, LevelData> levels = {
    'forest': const LevelData(
      imageNames: [
        'plx-1.png',
        'plx-2.png',
        'plx-3.png',
        'plx-4.png',
        'plx-5.png',
        'plx-6.png',
      ],
      folder: 'parallax',
      song: '8BitPlatformerLoop.wav',
      speed: 400, // Velocidad normal
    ),
    'desert': const LevelData(
      imageNames: [
        'desert_ground.png',
        'desert_midground_far.png',
        'desert_midground_near.png',
        'desert_foreground_far.png',
        'desert_foreground_near.png',
        'desert_background.png',
      ],
      folder: 'Desert',
      song: 'Desert_song.mp3',
      speed: 400, // Velocidad normal
    ),
    'snow': const LevelData(
      imageNames: [
        '1.png',
        '2.png',
        '3.png',
      ],
      folder: 'Montañas',
      song: 'Montañas_song.mp3',
      speed:
          400, // ¡MÁS VELOCIDAD PARA EL NIVEL DE MONTAÑAS! (Puedes ajustar este valor)
    ),
  };
}
