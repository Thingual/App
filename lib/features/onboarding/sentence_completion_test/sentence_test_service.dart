import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'sentence_question_model.dart';

/// Service to manage sentence completion questions
class SentenceTestService {
  static final SentenceTestService _instance = SentenceTestService._internal();

  factory SentenceTestService() {
    return _instance;
  }

  SentenceTestService._internal();

  List<SentenceCompletionQuestion>? _allQuestions;
  final _random = Random();

  /// Load all sentence completion questions from JSON asset
  Future<List<SentenceCompletionQuestion>> loadAllQuestions() async {
    if (_allQuestions != null) {
      return _allQuestions!;
    }

    final jsonString = await rootBundle.loadString(
      'assets/datasets/sentence_dataset.json',
    );
    final jsonData = json.decode(jsonString) as List<dynamic>;

    _allQuestions = jsonData
        .map(
          (item) =>
              SentenceCompletionQuestion.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    return _allQuestions!;
  }

  /// Get questions by difficulty level
  List<SentenceCompletionQuestion> getQuestionsByDifficulty(
    List<SentenceCompletionQuestion> questions,
    String difficulty,
  ) {
    return questions.where((q) => q.difficulty == difficulty).toList();
  }

  /// Randomly select one question from a list
  SentenceCompletionQuestion _selectRandomQuestion(
    List<SentenceCompletionQuestion> questions,
  ) {
    return questions[_random.nextInt(questions.length)];
  }

  /// Get 3 random questions (1 easy, 1 medium, 1 hard) and shuffle them
  Future<List<SentenceCompletionQuestion>>
  getRandomQuestionsForAssessment() async {
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
