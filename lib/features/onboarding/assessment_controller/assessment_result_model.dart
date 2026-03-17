/// Represents the result of a single question in the assessment
class AssessmentQuestionResult {
  final int questionId;
  final String sectionType; // 'grammar' or 'sentence_completion'
  final String difficulty; // 'easy', 'medium', 'hard'
  final String selectedAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final double responseTime; // in seconds

  AssessmentQuestionResult({
    required this.questionId,
    required this.sectionType,
    required this.difficulty,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.responseTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'sectionType': sectionType,
      'difficulty': difficulty,
      'selectedAnswer': selectedAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
      'responseTime': responseTime,
    };
  }
}

/// Represents the overall assessment results
class AssessmentResult {
  final List<AssessmentQuestionResult> grammarResults;
  final List<AssessmentQuestionResult> sentenceCompletionResults;
  final DateTime completedAt;

  AssessmentResult({
    required this.grammarResults,
    required this.sentenceCompletionResults,
    required this.completedAt,
  });

  /// Calculate grammar score as percentage
  double get grammarScore {
    if (grammarResults.isEmpty) return 0;
    final correctCount = grammarResults.where((r) => r.isCorrect).length;
    return (correctCount / grammarResults.length) * 100;
  }

  /// Calculate sentence completion score as percentage
  double get sentenceCompletionScore {
    if (sentenceCompletionResults.isEmpty) return 0;
    final correctCount = sentenceCompletionResults
        .where((r) => r.isCorrect)
        .length;
    return (correctCount / sentenceCompletionResults.length) * 100;
  }

  /// Calculate overall score as average of both sections
  double get overallScore {
    return (grammarScore + sentenceCompletionScore) / 2;
  }

  /// Calculate average response time for grammar section
  double get grammarAverageResponseTime {
    if (grammarResults.isEmpty) return 0;
    return grammarResults.fold<double>(
          0,
          (sum, result) => sum + result.responseTime,
        ) /
        grammarResults.length;
  }

  /// Calculate average response time for sentence completion section
  double get sentenceCompletionAverageResponseTime {
    if (sentenceCompletionResults.isEmpty) return 0;
    return sentenceCompletionResults.fold<double>(
          0,
          (sum, result) => sum + result.responseTime,
        ) /
        sentenceCompletionResults.length;
  }

  Map<String, dynamic> toMap() {
    return {
      'grammarResults': grammarResults.map((r) => r.toMap()).toList(),
      'sentenceCompletionResults': sentenceCompletionResults
          .map((r) => r.toMap())
          .toList(),
      'grammarScore': grammarScore,
      'sentenceCompletionScore': sentenceCompletionScore,
      'overallScore': overallScore,
      'completedAt': completedAt.toIso8601String(),
    };
  }
}
