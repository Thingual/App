import '../models/picture_model.dart';
import 'rule_engine.dart';
import 'llm_service.dart';

/// Service that combines rule-based and LLM scoring
///
/// Scoring Strategy:
/// 1. Always run rule-based scoring (fast)
/// 2. If LLM model is available, run LLM scoring
/// 3. Combine scores: 60% rule-based + 40% LLM
/// 4. Fallback to rule-based if LLM fails
class ScoringService {
  final RuleEngine ruleEngine;
  final LLMService llmService;

  ScoringService({required this.ruleEngine, required this.llmService});

  /// Score a picture description
  ///
  /// This combines:
  /// - Rule-based scoring (fast, always available)
  /// - LLM scoring (if model is available)
  Future<PictureScore> scoreDescription({
    required String userResponse,
    required List<String> keywords,
    required int responseTimeMs,
    required String imageContext,
    bool useIllm = false,
  }) async {
    debugPrint('=== Starting picture description scoring ===');
    debugPrint('useIllm flag: $useIllm');
    debugPrint('LLMService initialized: ${llmService.isInitialized}');
    debugPrint('User response length: ${userResponse.length} chars');

    // Always run rule-based scoring
    debugPrint('Running rule-based scoring...');
    final ruleScore = ruleEngine.scoreDescription(
      userResponse,
      keywords,
      responseTimeMs,
    );
    debugPrint('Rule-based score: ${ruleScore.score}');
    debugPrint(
      'Rule-based breakdown - Grammar: ${ruleScore.breakdown.grammar}, Vocab: ${ruleScore.breakdown.vocabulary}, Accuracy: ${ruleScore.breakdown.accuracy}, Detail: ${ruleScore.breakdown.detail}',
    );

    // Try LLM scoring if enabled and available
    LlmScoringResult? llmScore;
    bool isLlmScored = false;

    if (useIllm) {
      debugPrint('Checking LLM scoring eligibility...');
      if (llmService.isInitialized) {
        debugPrint('LLMService is initialized, attempting LLM scoring...');
        llmScore = await _runLlmScoring(userResponse, keywords, imageContext);
        isLlmScored = llmScore != null;
        if (isLlmScored) {
          debugPrint('LLM scoring succeeded! Score: ${llmScore.score}');
        } else {
          debugPrint('LLM scoring returned null, falling back to rule-based');
        }
      } else {
        debugPrint('LLMService NOT initialized! Cannot run LLM scoring.');
      }
    } else {
      debugPrint('useIllm is false, skipping LLM scoring');
    }

    // Combine scores
    final finalScore = _combineScores(ruleScore, llmScore);
    debugPrint('Final combined score: $finalScore (isLlmScored: $isLlmScored)');

    // Determine assigned CEFR level
    final assignedLevel = _assignCefrLevel(finalScore);
    debugPrint('Assigned CEFR level: $assignedLevel');
    debugPrint('=== Scoring complete ===');

    return PictureScore(
      userResponse: userResponse,
      responseTimeMs: responseTimeMs,
      ruleBasedResult: ruleScore,
      llmResult: llmScore,
      finalScore: finalScore,
      assignedLevel: assignedLevel,
      isLlmScored: isLlmScored,
    );
  }

  /// Run LLM scoring safely
  Future<LlmScoringResult?> _runLlmScoring(
    String userResponse,
    List<String> keywords,
    String imageContext,
  ) async {
    try {
      final prompt = PromptBuilder.buildEvaluationPrompt(
        userInput: userResponse,
        keywords: keywords,
        referenceDescription: imageContext,
      );

      final result = await llmService.inference(prompt);
      return result;
    } catch (e) {
      // Fallback to rule-based if LLM fails
      debugPrint('LLM scoring failed: $e');
      return null;
    }
  }

  /// Combine rule-based and LLM scores
  ///
  /// Formula:
  /// - If LLM available: 0.6 * ruleScore + 0.4 * llmScore
  /// - Otherwise: ruleScore
  double _combineScores(
    RuleBasedScoringResult ruleScore,
    LlmScoringResult? llmScore,
  ) {
    if (llmScore == null) {
      return ruleScore.score;
    }

    return (0.6 * ruleScore.score) + (0.4 * llmScore.score);
  }

  /// Assign CEFR level based on score
  String _assignCefrLevel(double score) {
    if (score < 25) return 'A1';
    if (score < 40) return 'A2';
    if (score < 60) return 'B1';
    if (score < 75) return 'B2';
    return 'C1';
  }
}

// Mock debug print for development
void debugPrint(String message) {
  // ignore: avoid_print
  print('[ScoringService] $message');
}
