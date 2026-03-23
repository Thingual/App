/// Represents the result of a single question in the assessment
class AssessmentQuestionResult {
  final int questionId;
  final String sectionType; // 'grammar' or 'sentence_completion'
  final String difficulty; // 'easy', 'medium', 'hard'
  final String selectedAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final double responseTime; // in seconds
  final double? numericScore; // 0..1 for listening similarity, etc

  AssessmentQuestionResult({
    required this.questionId,
    required this.sectionType,
    required this.difficulty,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.responseTime,
    this.numericScore,
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
      if (numericScore != null) 'numericScore': numericScore,
    };
  }
}

/// Represents the overall assessment results
class AssessmentResult {
  final List<AssessmentQuestionResult> grammarResults;
  final List<AssessmentQuestionResult> sentenceCompletionResults;
  final List<AssessmentQuestionResult> listeningResults;
  final DateTime completedAt;

  AssessmentResult({
    required this.grammarResults,
    required this.sentenceCompletionResults,
    required this.listeningResults,
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

  /// Listening score as a percentage.
  ///
  /// Uses per-question [numericScore] (0..1) when provided.
  double get listeningScore {
    if (listeningResults.isEmpty) return 0;

    final scored = listeningResults
        .map((r) => r.numericScore)
        .whereType<double>()
        .toList();

    if (scored.isEmpty) {
      final correctCount = listeningResults.where((r) => r.isCorrect).length;
      return (correctCount / listeningResults.length) * 100;
    }

    final avg = scored.fold<double>(0, (sum, s) => sum + s) / scored.length;
    return avg * 100;
  }

  /// Calculate overall score as average of both sections
  double get overallScore {
    final sections = <double>[];
    if (grammarResults.isNotEmpty) sections.add(grammarScore);
    if (sentenceCompletionResults.isNotEmpty) {
      sections.add(sentenceCompletionScore);
    }
    if (listeningResults.isNotEmpty) sections.add(listeningScore);

    if (sections.isEmpty) return 0;
    return sections.fold<double>(0, (sum, s) => sum + s) / sections.length;
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
      'listeningResults': listeningResults.map((r) => r.toMap()).toList(),
      'grammarScore': grammarScore,
      'sentenceCompletionScore': sentenceCompletionScore,
      'listeningScore': listeningScore,
      'overallScore': overallScore,
      'completedAt': completedAt.toIso8601String(),
    };
  }
}
