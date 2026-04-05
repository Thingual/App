import '../models/picture_model.dart';

/// Rule-based scoring engine for picture descriptions
/// Evaluates based on: grammar, vocabulary, accuracy, and detail
class RuleEngine {
  /// Score the user's description using rule-based heuristics
  ///
  /// Returns a score (0-100) and breakdown of individual components
  RuleBasedScoringResult scoreDescription(
    String userResponse,
    List<String> keywords,
    int responseTimeMs,
  ) {
    final trimmed = userResponse.trim();

    if (trimmed.isEmpty) {
      return RuleBasedScoringResult(
        score: 0,
        breakdown: ScoreBreakdown(
          grammar: 0,
          vocabulary: 0,
          accuracy: 0,
          detail: 0,
        ),
        responseTime: responseTimeMs,
      );
    }

    final grammarScore = _evaluateGrammar(trimmed);
    final vocabularyScore = _evaluateVocabulary(trimmed);
    final accuracyScore = _evaluateAccuracy(trimmed, keywords);
    final detailScore = _evaluateDetail(trimmed);

    final breakdown = ScoreBreakdown(
      grammar: grammarScore,
      vocabulary: vocabularyScore,
      accuracy: accuracyScore,
      detail: detailScore,
    );

    return RuleBasedScoringResult(
      score: breakdown.totalScore,
      breakdown: breakdown,
      responseTime: responseTimeMs,
    );
  }

  /// Evaluate grammar quality (0-25)
  /// Looks at sentence structure, capitalization, punctuation
  double _evaluateGrammar(String text) {
    double score = 0;

    // Check for proper capitalization at start
    if (text.isNotEmpty && text[0].toUpperCase() == text[0]) {
      score += 5;
    }

    // Check for sentence endings (period, question mark, exclamation)
    final sentences = text.split(RegExp(r'[.!?]'));
    if (sentences.length > 1) {
      score += 5; // Has multiple sentences
    }

    // Check for proper punctuation
    final punctuationCount = text.split(RegExp(r'[.!?]')).length - 1;
    final estimatedSentences = text.split(RegExp(r'[.!?]')).length;
    if (punctuationCount >= estimatedSentences - 1) {
      score += 5; // Good punctuation
    }

    // Check for comma usage (indicates complex sentences)
    if (text.contains(',')) {
      score += 5;
    }

    // Check for common grammatical structures
    if (text.contains(RegExp(r'\b(is|are|the)\b', caseSensitive: false))) {
      score += 5;
    }

    return score.clamp(0, 25);
  }

  /// Evaluate vocabulary quality (0-25)
  /// Looks at vocabulary diversity and word choice
  double _evaluateVocabulary(String text) {
    double score = 0;

    final words = text.toLowerCase().split(RegExp(r'\W+'));
    final validWords = words.where((w) => w.isNotEmpty).toList();

    if (validWords.isEmpty) return 0;

    // Vocabulary diversity: unique words / total words
    final uniqueWords = <String>{};
    uniqueWords.addAll(validWords);

    final diversity = uniqueWords.length / validWords.length;
    score = (diversity * 20).clamp(0, 20);

    // Bonus for longer words (indicates advanced vocabulary)
    final avgWordLength =
        validWords.fold<int>(0, (sum, word) => sum + word.length) /
        validWords.length;

    if (avgWordLength > 5) {
      score += 5;
    }

    return score.clamp(0, 25);
  }

  /// Evaluate accuracy based on keyword presence (0-25)
  /// Checks how many relevant keywords are mentioned
  double _evaluateAccuracy(String text, List<String> keywords) {
    final textLower = text.toLowerCase();
    int keywordsFound = 0;

    for (final keyword in keywords) {
      if (textLower.contains(keyword.toLowerCase())) {
        keywordsFound++;
      }
    }

    // Calculate keyword match ratio
    final ratio = keywords.isNotEmpty ? keywordsFound / keywords.length : 0;
    return ((ratio * 25).clamp(0, 25) as double);
  }

  /// Evaluate detail level (0-25)
  /// Looks at response length and descriptiveness
  double _evaluateDetail(String text) {
    final words = text.split(RegExp(r'\W+'));
    final validWords = words.where((w) => w.isNotEmpty).length;

    // Word count scoring
    double score = 0;

    if (validWords >= 50) {
      score = 25;
    } else if (validWords >= 40) {
      score = 22;
    } else if (validWords >= 30) {
      score = 18;
    } else if (validWords >= 20) {
      score = 15;
    } else if (validWords >= 10) {
      score = 10;
    } else if (validWords >= 5) {
      score = 5;
    }

    // Bonus for adjectives (descriptive words)
    if (text.contains(
      RegExp(
        r'\b(beautiful|good|nice|great|happy|focused|active)\b',
        caseSensitive: false,
      ),
    )) {
      score += 2;
    }

    return score.clamp(0, 25);
  }
}
