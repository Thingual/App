import 'package:flutter/services.dart' show rootBundle;

import '../models/lesson_models.dart';
import 'unit1_lesson_manifest.dart';
import 'unit2_lesson_manifest.dart';
import 'unit3_lesson_manifest.dart';
import 'unit4_lesson_manifest.dart';
import 'unit5_lesson_manifest.dart';
import 'unit6_lesson_manifest.dart';

class LessonLoader {
  LessonLoader._();

  static final LessonLoader instance = LessonLoader._();

  Future<LessonDefinition> loadLesson(String lessonId, {int unit = 1}) async {
    final assetPath = _getAssetPathForLessonId(lessonId, unit);
    if (assetPath == null) {
      throw StateError('Unknown lessonId: $lessonId for unit: $unit');
    }

    final jsonString = await rootBundle.loadString(assetPath);
    return LessonDefinition.fromJsonString(jsonString);
  }

  Future<LessonDefinition> loadUnit1Lesson(String lessonId) async {
    return loadLesson(lessonId, unit: 1);
  }

  Future<List<LessonDefinition>> loadUnitLessonMetadata(int unit) async {
    final results = <LessonDefinition>[];
    final lessons = _getManifestLessons(unit);

    for (final entry in lessons) {
      final assetPath = entry['assetPath'];
      if (assetPath == null) continue;
      final jsonString = await rootBundle.loadString(assetPath);
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

  Future<List<LessonDefinition>> loadUnit1LessonMetadata() async {
    return loadUnitLessonMetadata(1);
  }

  String? _getAssetPathForLessonId(String lessonId, int unit) {
    switch (unit) {
      case 1:
        return Unit1LessonManifest.assetPathForLessonId(lessonId);
      case 2:
        return Unit2LessonManifest.assetPathForLessonId(lessonId);
      case 3:
        return Unit3LessonManifest.assetPathForLessonId(lessonId);
      case 4:
        return Unit4LessonManifest.assetPathForLessonId(lessonId);
      case 5:
        return Unit5LessonManifest.assetPathForLessonId(lessonId);
      case 6:
        return Unit6LessonManifest.assetPathForLessonId(lessonId);
      default:
        return null;
    }
  }

  List<Map<String, String>> _getManifestLessons(int unit) {
    switch (unit) {
      case 1:
        return Unit1LessonManifest.lessons
            .map((e) => {'lessonId': e.lessonId, 'assetPath': e.assetPath})
            .toList();
      case 2:
        return Unit2LessonManifest.lessons
            .map((e) => {'lessonId': e.lessonId, 'assetPath': e.assetPath})
            .toList();
      case 3:
        return Unit3LessonManifest.lessons
            .map((e) => {'lessonId': e.lessonId, 'assetPath': e.assetPath})
            .toList();
      case 4:
        return Unit4LessonManifest.lessons
            .map((e) => {'lessonId': e.lessonId, 'assetPath': e.assetPath})
            .toList();
      case 5:
        return Unit5LessonManifest.lessons
            .map((e) => {'lessonId': e.lessonId, 'assetPath': e.assetPath})
            .toList();
      case 6:
        return Unit6LessonManifest.lessons
            .map((e) => {'lessonId': e.lessonId, 'assetPath': e.assetPath})
            .toList();
      default:
        return [];
    }
  }
}
