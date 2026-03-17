/// Represents a single sentence completion question
class SentenceCompletionQuestion {
  final int id;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;
  final String difficulty; // 'easy', 'medium', 'hard'

  SentenceCompletionQuestion({
    required this.id,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
    required this.difficulty,
  });

  /// Get list of all options
  List<String> get options => [optionA, optionB, optionC, optionD];

  /// Get label for each option (A, B, C, D)
  Map<String, String> get optionMap => {
    'A': optionA,
    'B': optionB,
    'C': optionC,
    'D': optionD,
  };

  /// Convert from JSON
  factory SentenceCompletionQuestion.fromJson(Map<String, dynamic> json) {
    return SentenceCompletionQuestion(
      id: json['id'],
      question: json['question'],
      optionA: json['option_a'],
      optionB: json['option_b'],
      optionC: json['option_c'],
      optionD: json['option_d'],
      correctAnswer: json['correct_answer'],
      difficulty: json['difficulty'],
    );
  }

  /// Check if selected answer is correct
  bool isAnswerCorrect(String selectedAnswer) {
    return selectedAnswer == correctAnswer;
  }
}
