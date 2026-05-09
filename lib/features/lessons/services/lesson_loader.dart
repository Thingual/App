import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

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
  
  // Cache for merged lesson files (unit 4, 5, 6)
  final Map<String, Map<String, dynamic>> _mergedLessonCache = {};

  Future<LessonDefinition> loadLesson(String lessonId, {int unit = 1}) async {
    final assetPath = _getAssetPathForLessonId(lessonId, unit);
    if (assetPath == null) {
      throw StateError('Unknown lessonId: $lessonId for unit: $unit');
    }

    final jsonString = await rootBundle.loadString(assetPath);
    
    // Try to parse as a single lesson first (Units 1-3)
    try {
      return LessonDefinition.fromJsonString(jsonString);
    } catch (e) {
      // If it fails, try parsing as an array of lessons (Units 4-6)
      try {
        final decoded = jsonDecode(jsonString) as List<dynamic>;
        for (final item in decoded) {
          if (item is Map<String, dynamic> && item['lesson_id'] == lessonId) {
            return LessonDefinition.fromJson(item);
          }
        }
        throw StateError('Lesson $lessonId not found in merged file: $assetPath');
      } catch (e2) {
        throw StateError('Could not parse lesson from $assetPath: $e2');
      }
    }
  }

  Future<LessonDefinition> loadUnit1Lesson(String lessonId) async {
    return loadLesson(lessonId, unit: 1);
  }

  Future<List<LessonDefinition>> loadUnitLessonMetadata(int unit) async {
    final results = <LessonDefinition>[];
    final lessons = _getManifestLessons(unit);
    final processedAssets = <String>{};

    for (final entry in lessons) {
      final assetPath = entry['assetPath'];
      if (assetPath == null || assetPath.isEmpty) continue;

      // For merged files, only load once and cache all lessons
      if (_isMergedLessonFile(assetPath)) {
        if (!processedAssets.contains(assetPath)) {
          processedAssets.add(assetPath);
          await _loadAndCacheMergedLessons(assetPath);
        }
        
        final lessonId = entry['lessonId'];
        if (lessonId != null && _mergedLessonCache.containsKey(lessonId)) {
          final lessonData = _mergedLessonCache[lessonId]!;
          results.add(
            LessonDefinition(
              lessonId: lessonData['lesson_id'],
              unit: lessonData['unit'],
              lessonNumber: lessonData['lesson_number'],
              level: lessonData['level'],
              title: lessonData['title'],
              description: lessonData['description'],
              estimatedMinutes: lessonData['estimated_minutes'],
              xpReward: lessonData['xp_reward'],
              tasks: const [],
            ),
          );
        }
      } else {
        // Individual lesson file
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
    }

    results.sort((a, b) => a.lessonNumber.compareTo(b.lessonNumber));
    return results;
  }

  Future<void> _loadAndCacheMergedLessons(String assetPath) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          final lessonId = item['lesson_id'] as String?;
          if (lessonId != null) {
            _mergedLessonCache[lessonId] = item;
          }
        }
      }
    } catch (e) {
      throw StateError('Could not load merged lessons from $assetPath: $e');
    }
  }

  bool _isMergedLessonFile(String assetPath) {
    return assetPath.contains('a1_unit_5') ||
        assetPath.contains('A1_unit-6') ||
        assetPath.contains('a1_unit_4/l02_to_l04') ||
        assetPath.contains('a1_unit_4/l05_to_l08');
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
