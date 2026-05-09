class Unit4LessonManifest {
  static const String unitTitle = 'Food, Shopping & Likes';

  static const List<Unit4LessonAsset> lessons = [
    Unit4LessonAsset(
      lessonId: 'a1_unit4_lesson01',
      assetPath: 'assets/datasets/lessons/a1_unit_4/l01.json',
    ),
    Unit4LessonAsset(
      lessonId: 'a1_unit4_lesson02',
      assetPath: 'assets/datasets/lessons/a1_unit_4/l02_to_l04.json',
    ),
    Unit4LessonAsset(
      lessonId: 'a1_unit4_lesson03',
      assetPath: 'assets/datasets/lessons/a1_unit_4/l02_to_l04.json',
    ),
    Unit4LessonAsset(
      lessonId: 'a1_unit4_lesson04',
      assetPath: 'assets/datasets/lessons/a1_unit_4/l02_to_l04.json',
    ),
    Unit4LessonAsset(
      lessonId: 'a1_unit4_lesson05',
      assetPath: 'assets/datasets/lessons/a1_unit_4/l05_to_l08.json',
    ),
    Unit4LessonAsset(
      lessonId: 'a1_unit4_lesson06',
      assetPath: 'assets/datasets/lessons/a1_unit_4/l05_to_l08.json',
    ),
    Unit4LessonAsset(
      lessonId: 'a1_unit4_lesson07',
      assetPath: 'assets/datasets/lessons/a1_unit_4/l05_to_l08.json',
    ),
    Unit4LessonAsset(
      lessonId: 'a1_unit4_lesson08',
      assetPath: 'assets/datasets/lessons/a1_unit_4/l05_to_l08.json',
    ),
  ];

  static String? assetPathForLessonId(String lessonId) {
    for (final entry in lessons) {
      if (entry.lessonId == lessonId) return entry.assetPath;
    }
    return null;
  }
}

class Unit4LessonAsset {
  final String lessonId;
  final String assetPath;

  const Unit4LessonAsset({required this.lessonId, required this.assetPath});
}
