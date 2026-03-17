import 'package:flutter/material.dart';
import 'assessment_result_model.dart';

/// Controller to manage the overall assessment workflow
class AssessmentController extends ChangeNotifier {
  final List<AssessmentQuestionResult> _grammarResults = [];
  final List<AssessmentQuestionResult> _sentenceResults = [];

  List<AssessmentQuestionResult> get grammarResults => _grammarResults;
  List<AssessmentQuestionResult> get sentenceResults => _sentenceResults;

  /// Add a grammar question result
  void addGrammarResult(AssessmentQuestionResult result) {
    _grammarResults.add(result);
    notifyListeners();
  }

  /// Add a sentence completion question result
  void addSentenceResult(AssessmentQuestionResult result) {
    _sentenceResults.add(result);
    notifyListeners();
  }

  /// Get the final assessment result
  AssessmentResult? getFinalResult() {
    if (_grammarResults.isEmpty || _sentenceResults.isEmpty) {
      return null;
    }

    return AssessmentResult(
      grammarResults: _grammarResults,
      sentenceCompletionResults: _sentenceResults,
      completedAt: DateTime.now(),
    );
  }

  /// Clear all results
  void clearResults() {
    _grammarResults.clear();
    _sentenceResults.clear();
    notifyListeners();
  }

  /// Reset controller for new assessment
  void reset() {
    clearResults();
  }
}
