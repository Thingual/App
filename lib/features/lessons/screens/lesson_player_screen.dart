import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../core/constants/brand_colors.dart';
import '../../../core/constants/theme.dart';
import '../../../shared/widgets/thingual_widgets.dart';
import '../engine/task_evaluator.dart';
import '../models/lesson_models.dart';
import '../progress/lesson_metrics.dart';
import '../progress/lesson_progress_repository.dart';
import '../services/lesson_loader.dart';
import '../widgets/lesson_task_widgets.dart';
import 'lesson_complete_screen.dart';

class LessonPlayerScreen extends StatefulWidget {
  final String lessonId;

  const LessonPlayerScreen({required this.lessonId, super.key});

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  late final Stopwatch _lessonStopwatch;
  late final Stopwatch _taskStopwatch;

  LessonDefinition? _lesson;
  String? _error;

  int _index = 0;
  bool _isSubmitted = false;
  TaskDraft _draft = const TaskDraft(canSubmit: false, payload: null);
  TaskEvaluation? _evaluation;

  int _correct = 0;
  int _totalScored = 0;
  int _mistakes = 0;
  int _scoredResponseTimeMs = 0;

  final Map<String, int> _scoredByCategoryTotal = {};
  final Map<String, int> _scoredByCategoryCorrect = {};

  bool get _isLoaded => _lesson != null && _error == null;

  LessonTask? get _currentTask {
    final lesson = _lesson;
    if (lesson == null) return null;
    if (_index < 0 || _index >= lesson.tasks.length) return null;
    return lesson.tasks[_index];
  }

  @override
  void initState() {
    super.initState();
    _lessonStopwatch = Stopwatch()..start();
    _taskStopwatch = Stopwatch()..start();
    _load();
  }

  @override
  void dispose() {
    _lessonStopwatch.stop();
    _taskStopwatch.stop();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final lesson = await LessonLoader.instance.loadUnit1Lesson(
        widget.lessonId,
      );
      if (!mounted) return;
      setState(() {
        _lesson = lesson;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<bool> _confirmExit() async {
    final lesson = _lesson;
    if (lesson == null) return true;

    final isLast = _index >= lesson.tasks.length - 1;
    if (isLast && _isSubmitted) return true;

    return (await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Leave lesson?'),
              content: const Text(
                'Your progress in this lesson won\'t be saved until you finish it.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Stay'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Leave'),
                ),
              ],
            );
          },
        )) ??
        false;
  }

  void _resetForNextTask() {
    _isSubmitted = false;
    _evaluation = null;
    _draft = const TaskDraft(canSubmit: false, payload: null);
    _taskStopwatch
      ..reset()
      ..start();
  }

  void _onDraftChanged(TaskDraft draft) {
    if (_isSubmitted) return;
    if (draft.canSubmit == _draft.canSubmit &&
        draft.payload == _draft.payload) {
      return;
    }

    void apply() {
      if (!mounted || _isSubmitted) return;
      setState(() => _draft = draft);
    }

    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => apply());
      return;
    }

    apply();
  }

  void _submit() {
    final task = _currentTask;
    if (task == null || _isSubmitted) return;

    final evaluation = TaskEvaluator.evaluate(task, _draft.payload);

    final responseMs = _taskStopwatch.elapsedMilliseconds;

    if (task.isScored) {
      _totalScored++;
      _scoredResponseTimeMs += responseMs;
      _scoredByCategoryTotal[task.category] =
          (_scoredByCategoryTotal[task.category] ?? 0) + 1;

      if (evaluation.isCorrect) {
        _correct++;
        _scoredByCategoryCorrect[task.category] =
            (_scoredByCategoryCorrect[task.category] ?? 0) + 1;
      } else {
        _mistakes++;
      }
    }

    setState(() {
      _isSubmitted = true;
      _evaluation = evaluation;
    });
  }

  Future<void> _next() async {
    final lesson = _lesson;
    if (lesson == null) return;

    final isLast = _index >= lesson.tasks.length - 1;
    if (!isLast) {
      setState(() {
        _index++;
        _resetForNextTask();
      });
      return;
    }

    final metrics = _buildMetrics(lesson);

    final navigator = Navigator.of(context);
    await LessonProgressRepository.instance.saveLessonMetrics(metrics);

    if (!mounted) return;

    final completed = await navigator.push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            LessonCompleteScreen(lessonTitle: lesson.title, metrics: metrics),
      ),
    );

    if (!mounted) return;

    navigator.pop(completed == true);
  }

  LessonMetrics _buildMetrics(LessonDefinition lesson) {
    final accuracy = _totalScored == 0 ? 1.0 : _correct / _totalScored;
    final responseTimeMs = _totalScored == 0
        ? 0
        : (_scoredResponseTimeMs ~/ _totalScored);

    final skillAccuracy = <String, double>{};
    for (final entry in _scoredByCategoryTotal.entries) {
      final total = entry.value;
      final correct = _scoredByCategoryCorrect[entry.key] ?? 0;
      skillAccuracy[entry.key] = total == 0 ? 0 : correct / total;
    }

    final now = DateTime.now().toUtc().toIso8601String();

    return LessonMetrics(
      lessonId: lesson.lessonId,
      lessonCompleted: true,
      correctAnswers: _correct,
      totalScoredAnswers: _totalScored,
      accuracy: accuracy,
      xpEarned: lesson.xpReward,
      mistakes: _mistakes,
      attemptCount: _totalScored,
      responseTimeMs: responseTimeMs,
      timeSpentMs: _lessonStopwatch.elapsedMilliseconds,
      completionDateIso: now,
      skillAccuracy: skillAccuracy,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lesson = _lesson;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final ok = await _confirmExit();
        if (!mounted) return;
        if (ok) navigator.pop(false);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(ThingualSpacing.lg),
            child: !_isLoaded
                ? _buildLoadingOrError(context)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TopBar(
                        title: lesson!.title,
                        progress: (lesson.tasks.isEmpty)
                            ? 0
                            : (_index + 1) / lesson.tasks.length,
                        current: _index + 1,
                        total: lesson.tasks.length,
                        onClose: () async {
                          final navigator = Navigator.of(context);
                          final ok = await _confirmExit();
                          if (!mounted) return;
                          if (ok) navigator.pop(false);
                        },
                      ),
                      const SizedBox(height: ThingualSpacing.lg),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: _TaskContainer(
                            key: ValueKey(
                              '${lesson.lessonId}:${_currentTask?.taskId ?? _index}',
                            ),
                            task: _currentTask!,
                            isSubmitted: _isSubmitted,
                            draft: _draft,
                            onChanged: _onDraftChanged,
                          ),
                        ),
                      ),
                      const SizedBox(height: ThingualSpacing.md),
                      if (_isSubmitted && _evaluation != null)
                        _FeedbackCard(evaluation: _evaluation!),
                      const SizedBox(height: ThingualSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: ThingualButton(
                              label: _isSubmitted ? 'Next' : 'Submit',
                              icon: _isSubmitted
                                  ? Icons.arrow_forward
                                  : Icons.check,
                              isEnabled: _isSubmitted ? true : _draft.canSubmit,
                              onPressed: _isSubmitted ? _next : _submit,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOrError(BuildContext context) {
    if (_error != null) {
      return Center(
        child: ThingualCard(
          padding: const EdgeInsets.all(ThingualSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(height: ThingualSpacing.sm),
              Text(
                'Could not load lesson',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: ThingualSpacing.sm),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: ThingualSpacing.lg),
              ThingualButton(
                label: 'Try again',
                icon: Icons.refresh,
                onPressed: _load,
              ),
            ],
          ),
        ),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }
}

class _TaskContainer extends StatelessWidget {
  final LessonTask task;
  final bool isSubmitted;
  final TaskDraft draft;
  final DraftChanged onChanged;

  const _TaskContainer({
    required this.task,
    required this.isSubmitted,
    required this.draft,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: ThingualSpacing.xl),
        child: LessonTaskBody(
          task: task,
          isSubmitted: isSubmitted,
          draft: draft,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final double progress;
  final int current;
  final int total;
  final VoidCallback onClose;

  const _TopBar({
    required this.title,
    required this.progress,
    required this.current,
    required this.total,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: ThingualSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    ThingualColors.deepIndigo,
                  ),
                ),
              ),
              const SizedBox(height: ThingualSpacing.xs),
              Text(
                'Task $current of $total',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: ThingualSpacing.md),
        IconButton(
          tooltip: 'Close',
          onPressed: onClose,
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final TaskEvaluation evaluation;

  const _FeedbackCard({required this.evaluation});

  @override
  Widget build(BuildContext context) {
    final isCorrect = evaluation.isCorrect;
    final bg = isCorrect
        ? Colors.green.withValues(alpha: 0.10)
        : Colors.red.withValues(alpha: 0.08);

    final border = isCorrect ? Colors.green : Colors.red;

    final title = isCorrect ? 'Correct' : 'Not quite';

    final details = <String>[];
    final explanation = evaluation.explanation;
    if (explanation != null && explanation.trim().isNotEmpty) {
      details.add(explanation.trim());
    }
    if (!isCorrect && evaluation.correctAnswer != null) {
      details.add('Correct answer: ${evaluation.correctAnswer}');
    }

    return ThingualCard(
      backgroundColor: bg,
      border: Border.all(color: border.withValues(alpha: 0.40)),
      padding: const EdgeInsets.all(ThingualSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: border),
          const SizedBox(width: ThingualSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: ThingualSpacing.xs),
                ...details.map(
                  (d) => Padding(
                    padding: const EdgeInsets.only(bottom: ThingualSpacing.xs),
                    child: Text(
                      d,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
