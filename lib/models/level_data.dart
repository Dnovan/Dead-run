// lib/models/level_data.dart

class LevelData {
  final List<String> imageNames;
  final String folder;
  final String song;
  final double speed;

  const LevelData({
    required this.imageNames,
    required this.folder,
    required this.song,
    required this.speed,
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
      speed: 10, // Velocidad base normal
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
      speed: 12, // Un poco más rápido
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
          36, // Compensamos por tener menos capas (3 vs 6) para igualar la velocidad del suelo
    ),
    'praderas': const LevelData(
      imageNames: [
        '1.png',
        '2.png',
        '3.png',
        '4.png',
        '5.png',
        '6.png',
      ],
      folder: 'Praderas',
      song: 'Praderas_song.mp3',
      speed: 13,
    ),
    'cuevacristal': const LevelData(
      imageNames: [
        'plan_5.png',
        'plan_4.png',
        'plan_3.png',
        'plan_2.png',
        'plan_1.png',
        'plan_6.png',
      ],
      folder: 'Cuevacristal',
      song: 'cave_song.mp3',
      speed: 13,
    ),
  };
}
