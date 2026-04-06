import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/picture_model.dart';

/// Service for running LLM inference via backend API
///
/// This service:
/// - Communicates with Python backend for LLM inference
/// - Uses llama-cpp-python for GGUF model execution
/// - Sends requests via FastAPI endpoint
/// - Parses JSON responses safely
abstract class LLMService {
  /// Check if the service is initialized
  bool get isInitialized;

  /// Initialize the LLM service
  Future<void> initialize(String? modelPath);

  /// Run inference on the given prompt
  /// Returns null if inference fails
  Future<LlmScoringResult?> inference(String prompt);

  /// Shutdown the service and free resources
  Future<void> shutdown();
}

/// Backend-based LLM Service implementation
/// Communicates with Python backend for actual model inference
class LLMServiceImpl extends LLMService {
  bool _initialized = false;
  final Dio _dio = Dio();
  String _backendUrl = 'http://localhost:8000';

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize(String? modelPath) async {
    // Get backend URL from environment or use default
    _backendUrl = _getBackendUrl();
    
    debugPrint('[LLMService] Initializing with backend: $_backendUrl');
    
    try {
      // Check if backend is running and LLM is ready
      final response = await _dio.get('$_backendUrl/api/llm/status').timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Backend not responding');
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        _initialized = data['initialized'] ?? data['ready'] ?? false;
        
        if (_initialized) {
          debugPrint('[LLMService] ✓ Backend LLM service ready');
        } else {
          debugPrint('[LLMService] ⚠ Backend LLM not yet initialized');
          debugPrint('[LLMService] Model will initialize on first use');
          _initialized = true; // Mark as initialized to allow inference
        }
      }
    } catch (e) {
      debugPrint('[LLMService] Warning: Backend not available yet');
      debugPrint('[LLMService] Will retry on first inference: $e');
      _initialized = true; // Still mark as initialized to allow retry
    }
  }

  @override
  Future<LlmScoringResult?> inference(String prompt) async {
    if (!_initialized) {
      throw StateError('LLMService not initialized');
    }

    try {
      final stopwatch = Stopwatch()..start();
      
      debugPrint('=' * 80);
      debugPrint('[LLMService] ========== LLM INFERENCE START ==========');
      debugPrint('[LLMService] Timestamp: ${DateTime.now().toIso8601String()}');
      debugPrint('=' * 80);

      // Extract user response from prompt for logging
      final userInput = _extractUserInput(prompt);
      
      debugPrint('\n[LLMService] STEP 1: PREPARING REQUEST');
      debugPrint('[LLMService]   Backend URL: $_backendUrl/api/llm/evaluate');
      debugPrint('[LLMService]   Request type: POST');
      debugPrint('[LLMService]   User input length: ${userInput.length} characters');

      // Step 2: Build backend request
      debugPrint('\n[LLMService] STEP 2: BUILDING BACKEND REQUEST');
      final requestData = {
        'user_response': userInput,
        'keywords': _extractKeywords(prompt),
        'reference_description': _extractReference(prompt),
      };
      debugPrint('[LLMService]   Payload size: ${jsonEncode(requestData).length} bytes');
      debugPrint('[LLMService]   ✓ Request prepared');

      // Step 3: Send to backend
      debugPrint('\n[LLMService] STEP 3: SENDING TO BACKEND');
      debugPrint('[LLMService]   Connecting to backend...');
      
      final response = await _dio.post(
        '$_backendUrl/api/llm/evaluate',
        data: requestData,
        options: Options(
          contentType: Headers.jsonContentType,
          receiveTimeout: const Duration(minutes: 5),
          sendTimeout: const Duration(seconds: 30),
        ),
      ).timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          throw TimeoutException('Backend inference timeout (>5 mins)');
        },
      );

      debugPrint('[LLMService]   ✓ Response received (${response.statusCode})');

      // Step 4: Parse response
      debugPrint('\n[LLMService] STEP 4: PARSING BACKEND RESPONSE');
      if (response.statusCode != 200) {
        throw Exception('Backend returned ${response.statusCode}');
      }

      final data = response.data as Map<String, dynamic>;
      debugPrint('[LLMService]   Response type: JSON');
      debugPrint('[LLMService]   Parsing evaluation result...');
      debugPrint('[LLMService]   ✓ JSON parsed successfully');

      // Step 5: Extract score
      debugPrint('\n[LLMService] STEP 5: EXTRACTING SCORES');
      final score = (data['score'] as num).toDouble();
      final cefrLevel = data['cefr_level'] as String;
      final breakdown = data['breakdown'] as Map<String, dynamic>;
      final feedback = data['feedback'] as String;
      
      debugPrint('[LLMService]   LLM Score: $score/100');
      debugPrint('[LLMService]   CEFR Level: $cefrLevel');
      debugPrint('[LLMService]   Confidence: HIGH');

      stopwatch.stop();

      // Step 6: Build result object
      debugPrint('\n[LLMService] STEP 6: BUILDING RESULT OBJECT');
      final result = LlmScoringResult(
        score: score,
        cefrLevel: cefrLevel,
        breakdown: ScoreBreakdown(
          grammar: ((breakdown['grammar'] as num).toDouble()),
          vocabulary: ((breakdown['vocabulary'] as num).toDouble()),
          accuracy: ((breakdown['accuracy'] as num).toDouble()),
          detail: ((breakdown['detail'] as num).toDouble()),
        ),
        feedback: feedback,
        inferenceTime: stopwatch.elapsedMilliseconds,
      );
      debugPrint('[LLMService]   ✓ Result object created');

      // Step 7: Final summary
      debugPrint('\n[LLMService] STEP 7: INFERENCE COMPLETE');
      debugPrint('[LLMService]   Score breakdown:');
      debugPrint('[LLMService]     - Grammar: ${result.breakdown.grammar}');
      debugPrint('[LLMService]     - Vocabulary: ${result.breakdown.vocabulary}');
      debugPrint('[LLMService]     - Accuracy: ${result.breakdown.accuracy}');
      debugPrint('[LLMService]     - Detail: ${result.breakdown.detail}');
      debugPrint('[LLMService]   Feedback: ${result.feedback}');
      debugPrint('[LLMService]   Backend processing time: ${stopwatch.elapsedMilliseconds}ms');

      debugPrint('\n' + '=' * 80);
      debugPrint('[LLMService] ========== LLM INFERENCE COMPLETE ==========');
      debugPrint('[LLMService] Status: SUCCESS ✓');
      debugPrint('[LLMService] Source: Python Backend (llama-cpp-python)');
      debugPrint('=' * 80 + '\n');

      return result;
    } catch (e) {
      debugPrint('\n[LLMService] ❌ INFERENCE ERROR: $e');
      debugPrint('[LLMService] Stack trace: ${e.toString()}');
      debugPrint('[LLMService] Attempting to recover...\n');
      
      // Return null to allow fallback to rule-based scoring
      return null;
    }
  }

  @override
  Future<void> shutdown() async {
    _initialized = false;
    _dio.close(force: true);
  }

  String _getBackendUrl() {
    // Check for environment variable first
    final envUrl = const String.fromEnvironment('BACKEND_URL', defaultValue: '');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    
    // Default to localhost for development
    return 'http://localhost:8000';
  }

  String _extractUserInput(String prompt) {
    // Extract user's description from the prompt
    final match = RegExp(r"User's description:\s*(.*?)(?=Evaluate|$)", dotAll: true)
        .firstMatch(prompt);
    return match?.group(1)?.trim() ?? '';
  }

  List<String> _extractKeywords(String prompt) {
    // Extract keywords from the prompt
    final match = RegExp(r'Key elements.*?:\s*(.*?)(?=User)', dotAll: true)
        .firstMatch(prompt);
    if (match == null) return [];
    
    final keywordsStr = match.group(1) ?? '';
    return keywordsStr.split(RegExp(r'[,;]\s*')).map((k) => k.trim()).toList();
  }

  String _extractReference(String prompt) {
    // Extract reference description from the prompt
    final match = RegExp(r'Image context.*?:\s*(.*?)(?=Key elements)', dotAll: true)
        .firstMatch(prompt);
    return match?.group(1)?.trim() ?? '';
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
  "cefr_level": "<A1|A2|B1|B2|C1>",
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
          !parsed.containsKey('cefr_level') ||
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
  print(message);
}
