class Unit5LessonManifest {
  static const String unitTitle = 'Family & Describing People';

  static const List<Unit5LessonAsset> lessons = [
    Unit5LessonAsset(
      lessonId: 'a1_unit5_lesson01',
      assetPath: 'assets/datasets/lessons/a1_unit_5.json',
    ),
    Unit5LessonAsset(
      lessonId: 'a1_unit5_lesson02',
      assetPath: 'assets/datasets/lessons/a1_unit_5.json',
    ),
    Unit5LessonAsset(
      lessonId: 'a1_unit5_lesson03',
      assetPath: 'assets/datasets/lessons/a1_unit_5.json',
    ),
    Unit5LessonAsset(
      lessonId: 'a1_unit5_lesson04',
      assetPath: 'assets/datasets/lessons/a1_unit_5.json',
    ),
    Unit5LessonAsset(
      lessonId: 'a1_unit5_lesson05',
      assetPath: 'assets/datasets/lessons/a1_unit_5.json',
    ),
    Unit5LessonAsset(
      lessonId: 'a1_unit5_lesson06',
      assetPath: 'assets/datasets/lessons/a1_unit_5.json',
    ),
    Unit5LessonAsset(
      lessonId: 'a1_unit5_lesson07',
      assetPath: 'assets/datasets/lessons/a1_unit_5.json',
    ),
    Unit5LessonAsset(
      lessonId: 'a1_unit5_lesson08',
      assetPath: 'assets/datasets/lessons/a1_unit_5.json',
    ),
  ];

  static String? assetPathForLessonId(String lessonId) {
    for (final entry in lessons) {
      if (entry.lessonId == lessonId) return entry.assetPath;
    }
    return null;
  }
}

class Unit5LessonAsset {
  final String lessonId;
  final String assetPath;

  const Unit5LessonAsset({
    required this.lessonId,
    required this.assetPath,
  });
}
