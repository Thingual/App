import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import 'listening_question_model.dart';

class ListeningTestService {
  static final ListeningTestService _instance =
      ListeningTestService._internal();

  factory ListeningTestService() => _instance;

  ListeningTestService._internal();

  List<ListeningQuestion>? _allQuestions;
  final _random = Random();

  Future<List<ListeningQuestion>> loadAllQuestions() async {
    if (_allQuestions != null) return _allQuestions!;

    final jsonString = await rootBundle.loadString(
      'assets/datasets/listening_dataset.json',
    );
    final jsonData = json.decode(jsonString) as List<dynamic>;

    _allQuestions = jsonData
        .map((item) => ListeningQuestion.fromJson(item as Map<String, dynamic>))
        .toList();

    return _allQuestions!;
  }

  List<ListeningQuestion> getQuestionsByDifficulty(
    List<ListeningQuestion> questions,
    String difficulty,
  ) {
    return questions.where((q) => q.difficulty == difficulty).toList();
  }

  ListeningQuestion _selectRandomQuestion(List<ListeningQuestion> questions) {
    return questions[_random.nextInt(questions.length)];
  }

  Future<List<ListeningQuestion>> getRandomQuestionsForAssessment() async {
    final allQuestions = await loadAllQuestions();

    final easy = getQuestionsByDifficulty(allQuestions, 'easy');
    final medium = getQuestionsByDifficulty(allQuestions, 'medium');
    final hard = getQuestionsByDifficulty(allQuestions, 'hard');

    final selectedQuestions = [
      _selectRandomQuestion(easy),
      _selectRandomQuestion(medium),
      _selectRandomQuestion(hard),
    ];

    selectedQuestions.shuffle(_random);
    return selectedQuestions;
  }

  void clearCache() {
    _allQuestions = null;
  }
}
