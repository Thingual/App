import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lesson_metrics.dart';

class LessonProgressRepository {
  LessonProgressRepository._();

  static final LessonProgressRepository instance = LessonProgressRepository._();

  static const _storageKey = 'thingual.lessonProgress.v1';

  final ValueNotifier<int> revision = ValueNotifier<int>(0);

  Future<Map<String, LessonMetrics>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return {};

    try {
      final decoded = json.decode(raw);
      if (decoded is! Map<String, dynamic>) return {};

      final results = <String, LessonMetrics>{};
      for (final entry in decoded.entries) {
        final lessonId = entry.key;
        final value = entry.value;
        if (value is Map<String, dynamic>) {
          results[lessonId] = LessonMetrics.fromJson(value);
        } else if (value is Map) {
          results[lessonId] = LessonMetrics.fromJson(
            value.map((k, v) => MapEntry(k.toString(), v)),
          );
        }
      }
      return results;
    } catch (_) {
      return {};
    }
  }

  Future<LessonMetrics?> loadForLesson(String lessonId) async {
    final all = await loadAll();
    return all[lessonId];
  }

  Future<void> saveLessonMetrics(LessonMetrics metrics) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await loadAll();

    all[metrics.lessonId] = metrics;

    final encoded = json.encode(
      all.map((key, value) => MapEntry(key, value.toJson())),
    );

    await prefs.setString(_storageKey, encoded);
    revision.value = revision.value + 1;
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    revision.value = revision.value + 1;
  }

  Future<AggregatedProgress> aggregate() async {
    final all = await loadAll();

    var lessonsCompleted = 0;
    var totalXp = 0;
    var totalMistakes = 0;
    var totalTimeMs = 0;

    for (final metrics in all.values) {
      if (metrics.lessonCompleted) lessonsCompleted++;
      totalXp += metrics.xpEarned;
      totalMistakes += metrics.mistakes;
      totalTimeMs += metrics.timeSpentMs;
    }

    return AggregatedProgress(
      lessonsCompleted: lessonsCompleted,
      totalXp: totalXp,
      totalMistakes: totalMistakes,
      totalTimeMs: totalTimeMs,
    );
  }
}

class AggregatedProgress {
  final int lessonsCompleted;
  final int totalXp;
  final int totalMistakes;
  final int totalTimeMs;

  const AggregatedProgress({
    required this.lessonsCompleted,
    required this.totalXp,
    required this.totalMistakes,
    required this.totalTimeMs,
  });
}
