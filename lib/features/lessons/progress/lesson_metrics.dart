class LessonMetrics {
  final String lessonId;
  final bool lessonCompleted;
  final int correctAnswers;
  final int totalScoredAnswers;
  final double accuracy;
  final int xpEarned;
  final int mistakes;
  final int attemptCount;
  final int responseTimeMs;
  final int timeSpentMs;
  final String completionDateIso;
  final Map<String, double> skillAccuracy;

  const LessonMetrics({
    required this.lessonId,
    required this.lessonCompleted,
    required this.correctAnswers,
    required this.totalScoredAnswers,
    required this.accuracy,
    required this.xpEarned,
    required this.mistakes,
    required this.attemptCount,
    required this.responseTimeMs,
    required this.timeSpentMs,
    required this.completionDateIso,
    required this.skillAccuracy,
  });

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'lessonCompleted': lessonCompleted,
      'correctAnswers': correctAnswers,
      'totalScoredAnswers': totalScoredAnswers,
      'accuracy': accuracy,
      'xpEarned': xpEarned,
      'mistakes': mistakes,
      'attemptCount': attemptCount,
      'responseTimeMs': responseTimeMs,
      'timeSpentMs': timeSpentMs,
      'completionDateIso': completionDateIso,
      'skillAccuracy': skillAccuracy,
    };
  }

  factory LessonMetrics.fromJson(Map<String, dynamic> json) {
    final skillAccuracy = <String, double>{};
    final raw = json['skillAccuracy'];
    if (raw is Map) {
      for (final entry in raw.entries) {
        final key = entry.key;
        final value = entry.value;
        if (key is String && value is num) {
          skillAccuracy[key] = value.toDouble();
        }
      }
    }

    return LessonMetrics(
      lessonId: (json['lessonId'] as String?) ?? '',
      lessonCompleted: (json['lessonCompleted'] as bool?) ?? false,
      correctAnswers: (json['correctAnswers'] as num?)?.toInt() ?? 0,
      totalScoredAnswers: (json['totalScoredAnswers'] as num?)?.toInt() ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0,
      xpEarned: (json['xpEarned'] as num?)?.toInt() ?? 0,
      mistakes: (json['mistakes'] as num?)?.toInt() ?? 0,
      attemptCount: (json['attemptCount'] as num?)?.toInt() ?? 0,
      responseTimeMs: (json['responseTimeMs'] as num?)?.toInt() ?? 0,
      timeSpentMs: (json['timeSpentMs'] as num?)?.toInt() ?? 0,
      completionDateIso: (json['completionDateIso'] as String?) ?? '',
      skillAccuracy: skillAccuracy,
    );
  }
}
