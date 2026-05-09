class Unit6LessonManifest {
  static const String unitTitle = 'Communication & Beyond';

  static const List<Unit6LessonAsset> lessons = [
    Unit6LessonAsset(
      lessonId: 'a1_unit6_lesson01',
      assetPath: 'assets/datasets/lessons/A1_unit-6.json',
    ),
    Unit6LessonAsset(
      lessonId: 'a1_unit6_lesson02',
      assetPath: 'assets/datasets/lessons/A1_unit-6.json',
    ),
    Unit6LessonAsset(
      lessonId: 'a1_unit6_lesson03',
      assetPath: 'assets/datasets/lessons/A1_unit-6.json',
    ),
    Unit6LessonAsset(
      lessonId: 'a1_unit6_lesson04',
      assetPath: 'assets/datasets/lessons/A1_unit-6.json',
    ),
    Unit6LessonAsset(
      lessonId: 'a1_unit6_lesson05',
      assetPath: 'assets/datasets/lessons/A1_unit-6.json',
    ),
    Unit6LessonAsset(
      lessonId: 'a1_unit6_lesson06',
      assetPath: 'assets/datasets/lessons/A1_unit-6.json',
    ),
    Unit6LessonAsset(
      lessonId: 'a1_unit6_lesson07',
      assetPath: 'assets/datasets/lessons/A1_unit-6.json',
    ),
    Unit6LessonAsset(
      lessonId: 'a1_unit6_lesson08',
      assetPath: 'assets/datasets/lessons/A1_unit-6.json',
    ),
  ];

  static String? assetPathForLessonId(String lessonId) {
    for (final entry in lessons) {
      if (entry.lessonId == lessonId) return entry.assetPath;
    }
    return null;
  }
}

class Unit6LessonAsset {
  final String lessonId;
  final String assetPath;

  const Unit6LessonAsset({required this.lessonId, required this.assetPath});
}
