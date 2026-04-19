class Unit1LessonManifest {
  static const String unitTitle = 'First steps in English';

  static const List<Unit1LessonAsset> lessons = [
    Unit1LessonAsset(
      lessonId: 'a1_unit1_lesson01',
      assetPath: 'assets/datasets/lessons/unit-1_A1/lesson_01_hello_goodbye.json',
    ),
    Unit1LessonAsset(
      lessonId: 'a1_unit1_lesson02',
      assetPath: 'assets/datasets/lessons/unit-1_A1/lesson_02_introducing_yourself.json',
    ),
    Unit1LessonAsset(
      lessonId: 'a1_unit1_lesson03',
      assetPath: 'assets/datasets/lessons/unit-1_A1/lesson_03_asking_about_others.json',
    ),
    Unit1LessonAsset(
      lessonId: 'a1_unit1_lesson04',
      assetPath: 'assets/datasets/lessons/unit-1_A1/lesson_04_family_friends.json',
    ),
    Unit1LessonAsset(
      lessonId: 'a1_unit1_lesson05',
      assetPath: 'assets/datasets/lessons/unit-1_A1/lesson_05_where_i_live.json',
    ),
    Unit1LessonAsset(
      lessonId: 'a1_unit1_lesson06',
      assetPath: 'assets/datasets/lessons/unit-1_A1/lesson_06_daily_routines.json',
    ),
    Unit1LessonAsset(
      lessonId: 'a1_unit1_lesson07',
      assetPath: 'assets/datasets/lessons/unit-1_A1/lesson_07_hobbies_preferences.json',
    ),
    Unit1LessonAsset(
      lessonId: 'a1_unit1_lesson08',
      assetPath: 'assets/datasets/lessons/unit-1_A1/lesson_08_unit1_review.json',
    ),
  ];

  static String? assetPathForLessonId(String lessonId) {
    for (final entry in lessons) {
      if (entry.lessonId == lessonId) return entry.assetPath;
    }
    return null;
  }
}

class Unit1LessonAsset {
  final String lessonId;
  final String assetPath;

  const Unit1LessonAsset({
    required this.lessonId,
    required this.assetPath,
  });
}
