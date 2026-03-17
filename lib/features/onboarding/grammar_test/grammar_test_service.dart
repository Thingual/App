import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'grammar_question_model.dart';

/// Service to manage grammar questions
class GrammarTestService {
  static final GrammarTestService _instance = GrammarTestService._internal();

  factory GrammarTestService() {
    return _instance;
  }

  GrammarTestService._internal();

  List<GrammarQuestion>? _allQuestions;
  final _random = Random();

  /// Load all grammar questions from JSON asset
  Future<List<GrammarQuestion>> loadAllQuestions() async {
    if (_allQuestions != null) {
      return _allQuestions!;
    }

    final jsonString = await rootBundle.loadString(
      'assets/datasets/grammar_questions_dataset.json',
    );
    final jsonData = json.decode(jsonString) as List<dynamic>;

    _allQuestions = jsonData
        .map((item) => GrammarQuestion.fromJson(item as Map<String, dynamic>))
        .toList();

    return _allQuestions!;
  }

  /// Get questions by difficulty level
  List<GrammarQuestion> getQuestionsByDifficulty(
    List<GrammarQuestion> questions,
    String difficulty,
  ) {
    return questions.where((q) => q.difficulty == difficulty).toList();
  }

  /// Randomly select one question from a list
  GrammarQuestion _selectRandomQuestion(List<GrammarQuestion> questions) {
    return questions[_random.nextInt(questions.length)];
  }

  /// Get 3 random questions (1 easy, 1 medium, 1 hard) and shuffle them
  Future<List<GrammarQuestion>> getRandomQuestionsForAssessment() async {
    final allQuestions = await loadAllQuestions();

    final easyQuestions = getQuestionsByDifficulty(allQuestions, 'easy');
    final mediumQuestions = getQuestionsByDifficulty(allQuestions, 'medium');
    final hardQuestions = getQuestionsByDifficulty(allQuestions, 'hard');

    // Select one random question from each difficulty level
    final selectedQuestions = [
      _selectRandomQuestion(easyQuestions),
      _selectRandomQuestion(mediumQuestions),
      _selectRandomQuestion(hardQuestions),
    ];

    // Shuffle the questions
    selectedQuestions.shuffle(_random);

    return selectedQuestions;
  }

  /// Clear cached questions (useful for testing or forcing reload)
  void clearCache() {
    _allQuestions = null;
  }
}
