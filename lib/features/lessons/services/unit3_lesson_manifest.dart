class Unit3LessonManifest {
  static const String unitTitle = 'Daily Routines & Time';

  static const List<Unit3LessonAsset> lessons = [
    Unit3LessonAsset(
      lessonId: 'a1_unit3_lesson01',
      assetPath: 'assets/datasets/lessons/a1_unit_3/a1_unit3_lesson01_body_health.json',
    ),
    Unit3LessonAsset(
      lessonId: 'a1_unit3_lesson02',
      assetPath: 'assets/datasets/lessons/a1_unit_3/a1_unit3_lesson02_at_the_doctor.json',
    ),
    Unit3LessonAsset(
      lessonId: 'a1_unit3_lesson03',
      assetPath: 'assets/datasets/lessons/a1_unit_3/a1_unit3_lesson03_clothes_colours.json',
    ),
    Unit3LessonAsset(
      lessonId: 'a1_unit3_lesson04',
      assetPath: 'assets/datasets/lessons/a1_unit_3/a1_unit3_lesson04_feelings_emotions.json',
    ),
    Unit3LessonAsset(
      lessonId: 'a1_unit3_lesson05',
      assetPath: 'assets/datasets/lessons/a1_unit_3/a1_unit3_lesson05_adjectives_opposites.json',
    ),
    Unit3LessonAsset(
      lessonId: 'a1_unit3_lesson06',
      assetPath: 'assets/datasets/lessons/a1_unit_3/a1_unit3_lesson06_home_rooms_furniture.json',
    ),
    Unit3LessonAsset(
      lessonId: 'a1_unit3_lesson07',
      assetPath: 'assets/datasets/lessons/a1_unit_3/a1_unit3_lesson07_animals_nature.json',
    ),
    Unit3LessonAsset(
      lessonId: 'a1_unit3_lesson08',
      assetPath: 'assets/datasets/lessons/a1_unit_3/a1_unit3_lesson08_unit3_review.json',
    ),
  ];

  static String? assetPathForLessonId(String lessonId) {
    for (final entry in lessons) {
      if (entry.lessonId == lessonId) return entry.assetPath;
    }
    return null;
  }
}

class Unit3LessonAsset {
  final String lessonId;
  final String assetPath;

  const Unit3LessonAsset({
    required this.lessonId,
    required this.assetPath,
  });
}
