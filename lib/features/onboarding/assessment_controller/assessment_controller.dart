import 'package:flutter/material.dart';
import 'assessment_result_model.dart';

/// Controller to manage the overall assessment workflow
class AssessmentController extends ChangeNotifier {
  final List<AssessmentQuestionResult> _grammarResults = [];
  final List<AssessmentQuestionResult> _sentenceResults = [];
  final List<AssessmentQuestionResult> _listeningResults = [];
  final List<AssessmentQuestionResult> _pictureDescriptionResults = [];

  List<AssessmentQuestionResult> get grammarResults => _grammarResults;
  List<AssessmentQuestionResult> get sentenceResults => _sentenceResults;
  List<AssessmentQuestionResult> get listeningResults => _listeningResults;
  List<AssessmentQuestionResult> get pictureDescriptionResults =>
      _pictureDescriptionResults;

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

  /// Add a listening question result
  void addListeningResult(AssessmentQuestionResult result) {
    _listeningResults.add(result);
    notifyListeners();
  }

  /// Add a picture description question result
  void addPictureDescriptionResult(AssessmentQuestionResult result) {
    _pictureDescriptionResults.add(result);
    notifyListeners();
  }

  /// Get the final assessment result
  AssessmentResult? getFinalResult() {
    if (_grammarResults.isEmpty ||
        _sentenceResults.isEmpty ||
        _listeningResults.isEmpty ||
        _pictureDescriptionResults.isEmpty) {
      return null;
    }

    return AssessmentResult(
      grammarResults: _grammarResults,
      sentenceCompletionResults: _sentenceResults,
      listeningResults: _listeningResults,
      pictureDescriptionResults: _pictureDescriptionResults,
      completedAt: DateTime.now(),
    );
  }

  /// Clear all results
  void clearResults() {
    _grammarResults.clear();
    _sentenceResults.clear();
    _listeningResults.clear();
    _pictureDescriptionResults.clear();
    notifyListeners();
  }

  /// Reset controller for new assessment
  void reset() {
    clearResults();
  }
}
