// lib/models/chapter_data.dart

class ChapterData {
  final int id;
  final String title;
  final String description;
  final String cinematicPath;
  final String levelId;
  final int targetScore; // Puntuación necesaria para "ganar" el capítulo

  const ChapterData({
    required this.id,
    required this.title,
    required this.description,
    required this.cinematicPath,
    required this.levelId,
    required this.targetScore,
  });

  static const List<ChapterData> chapters = [
    ChapterData(
      id: 1,
      title: "Capítulo 1: El Despertar",
      description: "Huye del desierto antes de que sea tarde.",
      cinematicPath: 'assets/images/cinematics/cinematic_1.png',
      levelId: 'forest', // Usamos el nivel del bosque (parallax)
      targetScore: 100, // Meta sencilla para probar
    ),
    ChapterData(
      id: 2,
      title: "Capítulo 2: Arenas Ardientes",
      description: "Sobrevive al calor del desierto.",
      cinematicPath: 'assets/images/cinematics/cinematic_2.png',
      levelId: 'desert', // Nivel del desierto
      targetScore: 150, // Meta un poco más difícil
    ),
  ];
}
