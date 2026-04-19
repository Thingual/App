import '../models/lesson_models.dart';

class TaskEvaluation {
  final bool isCorrect;
  final bool isScored;
  final String? explanation;
  final String? correctAnswer;

  const TaskEvaluation({
    required this.isCorrect,
    required this.isScored,
    this.explanation,
    this.correctAnswer,
  });
}

class TaskEvaluator {
  TaskEvaluator._();

  static TaskEvaluation evaluate(LessonTask task, Object? payload) {
    switch (task.type) {
      case 'learn_card':
      case 'lesson_summary':
        return TaskEvaluation(
          isCorrect: true,
          isScored: false,
          explanation: task.explanation,
        );
      case 'listen_repeat':
        return TaskEvaluation(
          isCorrect: true,
          isScored: false,
          explanation: task.explanation,
        );
      case 'mcq':
      case 'scenario_mcq':
      case 'error_correction':
        return _evaluateIndexed(task, payload);
      case 'fill_blank':
        return _evaluateFillBlank(task, payload);
      case 'match_pairs':
        return _evaluateMatchPairs(task, payload);
      case 'sort_words':
        return _evaluateSortWords(task, payload);
      case 'speaking':
        return _evaluateSpeaking(task, payload);
      default:
        return const TaskEvaluation(
          isCorrect: true,
          isScored: false,
          explanation: 'Task type not yet supported.',
        );
    }
  }

  static TaskEvaluation _evaluateIndexed(LessonTask task, Object? payload) {
    final correctIndex = (task.content['correct_index'] as num?)?.toInt();
    final options = task.content['options'];

    if (payload is! int || correctIndex == null || options is! List) {
      return const TaskEvaluation(
        isCorrect: false,
        isScored: true,
        explanation: 'Invalid answer.',
      );
    }

    final isCorrect = payload == correctIndex;
    final correctAnswer =
        correctIndex >= 0 && correctIndex < options.length
            ? options[correctIndex]?.toString()
            : null;

    return TaskEvaluation(
      isCorrect: isCorrect,
      isScored: true,
      explanation: task.explanation,
      correctAnswer: correctAnswer,
    );
  }

  static TaskEvaluation _evaluateFillBlank(LessonTask task, Object? payload) {
    final correct = task.content['correct']?.toString();
    if (correct == null || correct.isEmpty) {
      return const TaskEvaluation(
        isCorrect: false,
        isScored: true,
        explanation: 'Invalid task data.',
      );
    }

    final user = payload?.toString() ?? '';
    final isCorrect = _normalize(user) == _normalize(correct);

    return TaskEvaluation(
      isCorrect: isCorrect,
      isScored: true,
      explanation: task.explanation,
      correctAnswer: correct,
    );
  }

  static TaskEvaluation _evaluateMatchPairs(LessonTask task, Object? payload) {
    final pairsRaw = task.content['pairs'];
    if (pairsRaw is! List) {
      return const TaskEvaluation(
        isCorrect: false,
        isScored: true,
        explanation: 'Invalid task data.',
      );
    }

    final expected = <String, String>{};
    for (final item in pairsRaw) {
      if (item is Map) {
        final p = item['prompt']?.toString();
        final a = item['answer']?.toString();
        if (p != null && a != null) expected[p] = a;
      }
    }

    final user = <String, String>{};
    if (payload is Map) {
      for (final entry in payload.entries) {
        final k = entry.key?.toString();
        final v = entry.value?.toString();
        if (k != null && v != null) user[k] = v;
      }
    }

    if (user.length != expected.length) {
      return TaskEvaluation(
        isCorrect: false,
        isScored: true,
        explanation: task.explanation,
        correctAnswer: 'Match all pairs.',
      );
    }

    var ok = true;
    for (final entry in expected.entries) {
      if (_normalize(user[entry.key] ?? '') != _normalize(entry.value)) {
        ok = false;
        break;
      }
    }

    return TaskEvaluation(
      isCorrect: ok,
      isScored: true,
      explanation: task.explanation,
      correctAnswer: 'All pairs matched.',
    );
  }

  static TaskEvaluation _evaluateSortWords(LessonTask task, Object? payload) {
    final correctSentence = task.content['correct_sentence']?.toString();
    if (correctSentence == null || correctSentence.isEmpty) {
      return const TaskEvaluation(
        isCorrect: false,
        isScored: true,
        explanation: 'Invalid task data.',
      );
    }

    final words = <String>[];
    if (payload is List) {
      for (final w in payload) {
        words.add(w.toString());
      }
    }

    final userSentence = words.join(' ');
    final isCorrect =
        _normalizeSentence(userSentence) == _normalizeSentence(correctSentence);

    return TaskEvaluation(
      isCorrect: isCorrect,
      isScored: true,
      explanation: task.explanation,
      correctAnswer: correctSentence,
    );
  }

  static TaskEvaluation _evaluateSpeaking(LessonTask task, Object? payload) {
    final minWords = (task.content['min_words'] as num?)?.toInt() ?? 0;
    final text = payload?.toString() ?? '';

    final words = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.trim().isNotEmpty)
        .toList();

    final isCorrect = minWords <= 0 ? text.trim().isNotEmpty : words.length >= minWords;

    return TaskEvaluation(
      isCorrect: isCorrect,
      isScored: true,
      explanation: task.explanation ??
          (isCorrect
              ? 'Nice! Keep practicing aloud for natural rhythm.'
              : 'Try a bit longer — include the key phrases.'),
      correctAnswer: task.content['example_response']?.toString(),
    );
  }

  static String _normalize(String value) {
    return value.trim().toLowerCase();
  }

  static String _normalizeSentence(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
