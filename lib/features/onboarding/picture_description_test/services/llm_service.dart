import 'dart:async';
import 'dart:convert';
import '../models/picture_model.dart';

/// Service for running LLM inference on-device
///
/// This service:
/// - Loads GGUF models via native bridge (stub for now)
/// - Sends prompts to the model
/// - Parses JSON responses safely
/// - Runs inference in isolates to avoid blocking UI
abstract class LLMService {
  /// Check if the service is initialized
  bool get isInitialized;

  /// Initialize the LLM service with a model path
  Future<void> initialize(String modelPath);

  /// Run inference on the given prompt
  /// Returns null if inference fails
  Future<LlmScoringResult?> inference(String prompt);

  /// Shutdown the service and free resources
  Future<void> shutdown();
}

/// Stub implementation of LLMService for development
/// In production, this would use native FFI to call llama.cpp
class LLMServiceStub extends LLMService {
  bool _initialized = false;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize(String modelPath) async {
    // In production, this would:
    // 1. Load the GGUF model using FFI
    // 2. Initialize the inference context
    _initialized = true;
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<LlmScoringResult?> inference(String prompt) async {
    if (!_initialized) {
      throw StateError('LLMService not initialized');
    }

    try {
      debugPrint('[LLMService] Starting inference...');
      debugPrint('[LLMService] Prompt length: ${prompt.length} chars');

      // For now, run synchronously in the main isolate
      // In production, this would use Isolate.run for actual inference
      final stopwatch = Stopwatch()..start();

      // Simulate inference delay
      debugPrint(
        '[LLMService] Running simulated inference (2 second delay)...',
      );
      await Future.delayed(const Duration(milliseconds: 2000));

      stopwatch.stop();
      debugPrint(
        '[LLMService] Inference complete in ${stopwatch.elapsedMilliseconds}ms',
      );

      // Return mock result for development
      final result = LlmScoringResult(
        score: 75.0,
        cefrLevel: 'B1',
        breakdown: ScoreBreakdown(
          grammar: 18,
          vocabulary: 19,
          accuracy: 20,
          detail: 18,
        ),
        feedback: 'Good description with clear details.',
        inferenceTime: stopwatch.elapsedMilliseconds,
      );

      debugPrint('[LLMService] Returning mock LLM score: ${result.score}');
      return result;
    } catch (e) {
      debugPrint('[LLMService] Inference error: $e');
      return null;
    }
  }

  @override
  Future<void> shutdown() async {
    _initialized = false;
  }
}

/// Builder for LLM evaluation prompts
class PromptBuilder {
  static const String systemPrompt = '''You are an English language evaluator.

Evaluate the user's description of an image based on the following criteria:

1. Grammar (0-25): Sentence structure, punctuation, capitalization
2. Vocabulary (0-25): Word choice, diversity, complexity
3. Accuracy (0-25): How well the description matches the image context and keywords
4. Detail (0-25): Level of descriptiveness and completeness

Return ONLY a valid JSON response with this exact structure:
{
  "score": <number 0-100>,
  "level": "<A1|A2|B1|B2|C1>",
  "breakdown": {
    "grammar": <0-25>,
    "vocabulary": <0-25>,
    "accuracy": <0-25>,
    "detail": <0-25>
  },
  "feedback": "<short explanation of the evaluation>"
}''';

  /// Build evaluation prompt for the given input
  static String buildEvaluationPrompt({
    required String userInput,
    required List<String> keywords,
    required String referenceDescription,
  }) {
    return '''$systemPrompt

Image context (reference description):
$referenceDescription

Key elements that should be mentioned:
${keywords.join(', ')}

User's description:
$userInput

Evaluate and respond with JSON only:''';
  }

  /// Safely parse LLM response to JSON
  static Map<String, dynamic>? parseResponse(String response) {
    try {
      // Extract JSON from response (model might include extra text)
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(response);
      if (jsonMatch == null) return null;

      final jsonStr = jsonMatch.group(0) ?? '';
      final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;

      // Validate required fields
      if (!parsed.containsKey('score') ||
          !parsed.containsKey('level') ||
          !parsed.containsKey('breakdown') ||
          !parsed.containsKey('feedback')) {
        return null;
      }

      return parsed;
    } catch (e) {
      debugPrint('Failed to parse LLM response: $e');
      return null;
    }
  }
}

// Dart's debugPrint for development logging
void debugPrint(String message) {
  // ignore: avoid_print
  print('[LLMService] $message');
}
