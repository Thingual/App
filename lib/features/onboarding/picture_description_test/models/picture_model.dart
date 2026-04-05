/// Represents a single image for picture description assessment
class Picture {
  final int id;
  final String imagePath;
  final List<String> keywords;
  final Map<String, CefrDescription> cefrLevels;

  Picture({
    required this.id,
    required this.imagePath,
    required this.keywords,
    required this.cefrLevels,
  });

  /// Get reference description for a specific CEFR level
  String? getReferenceByCefr(String cefrLevel) {
    return cefrLevels[cefrLevel]?.description;
  }

  /// Factory constructor to create from JSON
  factory Picture.fromJson(Map<String, dynamic> json) {
    final cefrMap = <String, CefrDescription>{};
    final cefrLevels = json['cefr_levels'] as Map<String, dynamic>? ?? {};

    for (final entry in cefrLevels.entries) {
      cefrMap[entry.key] = CefrDescription.fromJson(entry.value);
    }

    // Get image path from JSON - use as-is without normalization
    String imagePath = json['image_path'] as String;
    print('[Picture.fromJson] Original imagePath from JSON: "$imagePath"');

    return Picture(
      id: json['id'] as int,
      imagePath: imagePath,
      keywords: List<String>.from(json['keywords'] as List<dynamic>),
      cefrLevels: cefrMap,
    );
  }
}

/// CEFR level description for a picture
class CefrDescription {
  final String level;
  final String description;

  CefrDescription({required this.level, required this.description});

  factory CefrDescription.fromJson(Map<String, dynamic> json) {
    return CefrDescription(
      level: json['level'] as String,
      description: json['description'] as String,
    );
  }
}

/// Represents the breakdown of a picture description score
class ScoreBreakdown {
  final double grammar;
  final double vocabulary;
  final double accuracy;
  final double detail;

  ScoreBreakdown({
    required this.grammar,
    required this.vocabulary,
    required this.accuracy,
    required this.detail,
  });

  /// Get total score (sum of all components / 4)
  double get totalScore => (grammar + vocabulary + accuracy + detail) / 4;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'grammar': grammar,
      'vocabulary': vocabulary,
      'accuracy': accuracy,
      'detail': detail,
    };
  }

  factory ScoreBreakdown.fromJson(Map<String, dynamic> json) {
    return ScoreBreakdown(
      grammar: (json['grammar'] as num).toDouble(),
      vocabulary: (json['vocabulary'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      detail: (json['detail'] as num).toDouble(),
    );
  }
}

/// Result from rule-based scoring
class RuleBasedScoringResult {
  final double score;
  final ScoreBreakdown breakdown;
  final int responseTime; // in milliseconds

  RuleBasedScoringResult({
    required this.score,
    required this.breakdown,
    required this.responseTime,
  });
}

/// Result from LLM-based scoring
class LlmScoringResult {
  final double score;
  final String cefrLevel;
  final ScoreBreakdown breakdown;
  final String feedback;
  final int inferenceTime; // in milliseconds

  LlmScoringResult({
    required this.score,
    required this.cefrLevel,
    required this.breakdown,
    required this.feedback,
    required this.inferenceTime,
  });

  factory LlmScoringResult.fromJson(Map<String, dynamic> json) {
    return LlmScoringResult(
      score: (json['score'] as num).toDouble(),
      cefrLevel: json['level'] as String,
      breakdown: ScoreBreakdown.fromJson(
        json['breakdown'] as Map<String, dynamic>,
      ),
      feedback: json['feedback'] as String,
      inferenceTime: 0, // Populated by the service
    );
  }
}

/// Combined scoring result (rule-based + LLM hybrid)
class PictureScore {
  final String userResponse;
  final int responseTimeMs;
  final RuleBasedScoringResult ruleBasedResult;
  final LlmScoringResult? llmResult;
  final double finalScore;
  final String assignedLevel;
  final bool isLlmScored;

  PictureScore({
    required this.userResponse,
    required this.responseTimeMs,
    required this.ruleBasedResult,
    this.llmResult,
    required this.finalScore,
    required this.assignedLevel,
    required this.isLlmScored,
  });

  /// Get effective breakdown (LLM if available, otherwise rule-based)
  ScoreBreakdown get effectiveBreakdown =>
      llmResult?.breakdown ?? ruleBasedResult.breakdown;

  /// Get effective CEFR level
  String get cefrLevel => llmResult?.cefrLevel ?? assignedLevel;

  /// Get feedback text
  String? get feedback => llmResult?.feedback;

  Map<String, dynamic> toJson() {
    return {
      'userResponse': userResponse,
      'responseTimeMs': responseTimeMs,
      'ruleBasedScore': ruleBasedResult.score,
      'llmScore': llmResult?.score,
      'finalScore': finalScore,
      'cefrLevel': assignedLevel,
      'isLlmScored': isLlmScored,
    };
  }
}
