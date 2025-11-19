// lib/models/chapter_data.dart

class ChapterData {
  final int id;
  final String title;
  final String description;
  final String cinematicPath;
  final String levelId;
  final int targetScore; // Puntuación necesaria para "ganar" el capítulo
  final List<String> lore;

  const ChapterData({
    required this.id,
    required this.title,
    required this.description,
    required this.cinematicPath,
    required this.levelId,
    required this.targetScore,
    required this.lore,
  });

  static const List<ChapterData> chapters = [
    ChapterData(
      id: 1,
      title: "Capítulo 1: El Despertar",
      description: "Huye del bosque antes de que sea tarde.",
      cinematicPath: 'assets/images/cinematics/cinematic_1.png',
      levelId: 'forest', // Usamos el nivel del bosque (parallax)
      targetScore: 100, // Meta sencilla para probar
      lore: [
        "Dino despierta en un mundo extraño, donde el silencio es inquietante.",
        "El instinto le grita que corra. Algo oscuro se aproxima.",
        "¡No mires atrás, solo corre!",
      ],
    ),
    ChapterData(
      id: 2,
      title: "Capítulo 2: Arenas Ardientes",
      description: "Sobrevive al calor del desierto.",
      cinematicPath: 'assets/images/cinematics/cinematic_2.png',
      levelId: 'desert', // Nivel del desierto
      targetScore: 150, // Meta un poco más difícil
      lore: [
        "El bosque ha quedado atrás, pero el peligro persiste.",
        "El desierto es implacable. El sol quema y la arena es traicionera.",
        "Un paso en falso podría ser el último.",
      ],
    ),
    ChapterData(
      id: 3,
      title: "Capítulo 3: Cumbres Gélidas",
      description: "Atraviesa las montañas heladas.",
      cinematicPath: 'assets/images/cinematics/cinematic_3.png',
      levelId: 'snow', // Nivel de nieve/montañas
      targetScore: 200, // Meta final
      lore: [
        "El calor da paso a un frío mortal en las Cumbres Gélidas.",
        "El viento aúlla como una bestia hambrienta.",
        "La cima es la única esperanza. ¡Resiste, Dino!",
      ],
    ),
  ];
}
