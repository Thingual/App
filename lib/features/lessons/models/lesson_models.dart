import 'dart:convert';

class LessonDefinition {
  final String lessonId;
  final int unit;
  final int lessonNumber;
  final String level;
  final String title;
  final String description;
  final int estimatedMinutes;
  final int xpReward;
  final List<LessonTask> tasks;

  const LessonDefinition({
    required this.lessonId,
    required this.unit,
    required this.lessonNumber,
    required this.level,
    required this.title,
    required this.description,
    required this.estimatedMinutes,
    required this.xpReward,
    required this.tasks,
  });

  factory LessonDefinition.fromJson(Map<String, dynamic> json) {
    final tasks = (json['tasks'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(LessonTask.fromJson)
        .toList();
    tasks.sort((a, b) => a.order.compareTo(b.order));

    return LessonDefinition(
      lessonId: (json['lesson_id'] as String?) ?? '',
      unit: (json['unit'] as num?)?.toInt() ?? 0,
      lessonNumber: (json['lesson_number'] as num?)?.toInt() ?? 0,
      level: (json['level'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      estimatedMinutes: (json['estimated_minutes'] as num?)?.toInt() ?? 0,
      xpReward: (json['xp_reward'] as num?)?.toInt() ?? 0,
      tasks: tasks,
    );
  }

  static LessonDefinition fromJsonString(String jsonString) {
    return LessonDefinition.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }
}

class LessonTask {
  final String taskId;
  final int order;
  final String type;
  final String category;
  final String title;
  final Map<String, dynamic> content;

  const LessonTask({
    required this.taskId,
    required this.order,
    required this.type,
    required this.category,
    required this.title,
    required this.content,
  });

  factory LessonTask.fromJson(Map<String, dynamic> json) {
    return LessonTask(
      taskId: (json['task_id'] as String?) ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
      type: (json['type'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      content: (json['content'] as Map<String, dynamic>?) ?? const {},
    );
  }

  bool get isScored {
    switch (type) {
      case 'mcq':
      case 'fill_blank':
      case 'match_pairs':
      case 'sort_words':
      case 'scenario_mcq':
      case 'error_correction':
      case 'speaking':
        return true;
      default:
        return false;
    }
  }

  String? get explanation {
    final value = content['explanation'];
    return value is String ? value : null;
  }
}
