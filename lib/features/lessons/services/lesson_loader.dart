import 'package:flutter/services.dart' show rootBundle;

import '../models/lesson_models.dart';
import 'unit1_lesson_manifest.dart';

class LessonLoader {
  LessonLoader._();

  static final LessonLoader instance = LessonLoader._();

  Future<LessonDefinition> loadUnit1Lesson(String lessonId) async {
    final assetPath = Unit1LessonManifest.assetPathForLessonId(lessonId);
    if (assetPath == null) {
      throw StateError('Unknown Unit 1 lessonId: $lessonId');
    }

    final jsonString = await rootBundle.loadString(assetPath);
    return LessonDefinition.fromJsonString(jsonString);
  }

  Future<List<LessonDefinition>> loadUnit1LessonMetadata() async {
    final results = <LessonDefinition>[];

    for (final entry in Unit1LessonManifest.lessons) {
      final jsonString = await rootBundle.loadString(entry.assetPath);
      final lesson = LessonDefinition.fromJsonString(jsonString);

      results.add(
        LessonDefinition(
          lessonId: lesson.lessonId,
          unit: lesson.unit,
          lessonNumber: lesson.lessonNumber,
          level: lesson.level,
          title: lesson.title,
          description: lesson.description,
          estimatedMinutes: lesson.estimatedMinutes,
          xpReward: lesson.xpReward,
          tasks: const [],
        ),
      );
    }

    results.sort((a, b) => a.lessonNumber.compareTo(b.lessonNumber));
    return results;
  }
}
