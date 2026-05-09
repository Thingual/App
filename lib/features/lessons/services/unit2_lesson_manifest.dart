class Unit2LessonManifest {
  static const String unitTitle = 'Numbers, Colors & Descriptions';

  static const List<Unit2LessonAsset> lessons = [
    Unit2LessonAsset(
      lessonId: 'a1_unit2_lesson01',
      assetPath: 'assets/datasets/lessons/a1_unit_2/a1_u2_l01.json',
    ),
    Unit2LessonAsset(
      lessonId: 'a1_unit2_lesson02',
      assetPath: 'assets/datasets/lessons/a1_unit_2/a1_u2_l02.json',
    ),
    Unit2LessonAsset(
      lessonId: 'a1_unit2_lesson03',
      assetPath: 'assets/datasets/lessons/a1_unit_2/a1_u2_l03.json',
    ),
    Unit2LessonAsset(
      lessonId: 'a1_unit2_lesson04',
      assetPath: 'assets/datasets/lessons/a1_unit_2/a1_u2_l04.json',
    ),
    Unit2LessonAsset(
      lessonId: 'a1_unit2_lesson05',
      assetPath: 'assets/datasets/lessons/a1_unit_2/a1_u2_l05.json',
    ),
    Unit2LessonAsset(
      lessonId: 'a1_unit2_lesson06',
      assetPath: 'assets/datasets/lessons/a1_unit_2/a1_u2_l06.json',
    ),
    Unit2LessonAsset(
      lessonId: 'a1_unit2_lesson07',
      assetPath: 'assets/datasets/lessons/a1_unit_2/a1_u2_l07.json',
    ),
    Unit2LessonAsset(
      lessonId: 'a1_unit2_lesson08',
      assetPath: 'assets/datasets/lessons/a1_unit_2/a1_u2_l08.json',
    ),
  ];

  static String? assetPathForLessonId(String lessonId) {
    for (final entry in lessons) {
      if (entry.lessonId == lessonId) return entry.assetPath;
    }
    return null;
  }
}

class Unit2LessonAsset {
  final String lessonId;
  final String assetPath;

  const Unit2LessonAsset({required this.lessonId, required this.assetPath});
}
