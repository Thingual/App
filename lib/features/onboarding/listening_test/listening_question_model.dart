class ListeningQuestion {
  final int id;
  final String sentence;
  final String difficulty; // 'easy', 'medium', 'hard'

  ListeningQuestion({
    required this.id,
    required this.sentence,
    required this.difficulty,
  });

  factory ListeningQuestion.fromJson(Map<String, dynamic> json) {
    return ListeningQuestion(
      id: (json['id'] as num).toInt(),
      sentence: (json['sentence'] as String).trim(),
      difficulty: (json['difficulty'] as String).trim(),
    );
  }
}
