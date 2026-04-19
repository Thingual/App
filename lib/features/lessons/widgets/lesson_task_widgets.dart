import 'package:flutter/material.dart';

import '../../../core/constants/brand_colors.dart';
import '../../../core/constants/theme.dart';
import '../../../shared/widgets/thingual_widgets.dart';
import '../models/lesson_models.dart';

class TaskDraft {
  final bool canSubmit;
  final Object? payload;

  const TaskDraft({required this.canSubmit, required this.payload});
}

typedef DraftChanged = void Function(TaskDraft draft);

class LessonTaskBody extends StatelessWidget {
  final LessonTask task;
  final bool isSubmitted;
  final TaskDraft draft;
  final DraftChanged onChanged;

  const LessonTaskBody({
    required this.task,
    required this.isSubmitted,
    required this.draft,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    switch (task.type) {
      case 'learn_card':
        return LearnCardTask(
          task: task,
          isSubmitted: isSubmitted,
          onChanged: onChanged,
        );
      case 'mcq':
        return McqTask(
          task: task,
          isSubmitted: isSubmitted,
          onChanged: onChanged,
        );
      case 'scenario_mcq':
        return ScenarioMcqTask(
          task: task,
          isSubmitted: isSubmitted,
          onChanged: onChanged,
        );
      case 'fill_blank':
        return FillBlankTask(
          task: task,
          isSubmitted: isSubmitted,
          onChanged: onChanged,
        );
      case 'match_pairs':
        return MatchPairsTask(
          task: task,
          isSubmitted: isSubmitted,
          onChanged: onChanged,
        );
      case 'sort_words':
        return SortWordsTask(
          task: task,
          isSubmitted: isSubmitted,
          onChanged: onChanged,
        );
      case 'error_correction':
        return ErrorCorrectionTask(
          task: task,
          isSubmitted: isSubmitted,
          onChanged: onChanged,
        );
      case 'listen_repeat':
        return ListenRepeatTask(
          task: task,
          isSubmitted: isSubmitted,
          onChanged: onChanged,
        );
      case 'speaking':
        return SpeakingTask(
          task: task,
          isSubmitted: isSubmitted,
          onChanged: onChanged,
        );
      case 'lesson_summary':
        return LessonSummaryTask(
          task: task,
          isSubmitted: isSubmitted,
          onChanged: onChanged,
        );
      default:
        return ThingualCard(
          child: Padding(
            padding: const EdgeInsets.all(ThingualSpacing.lg),
            child: Text('Unsupported task type: ${task.type}'),
          ),
        );
    }
  }
}

class LearnCardTask extends StatefulWidget {
  final LessonTask task;
  final bool isSubmitted;
  final DraftChanged onChanged;

  const LearnCardTask({
    required this.task,
    required this.isSubmitted,
    required this.onChanged,
    super.key,
  });

  @override
  State<LearnCardTask> createState() => _LearnCardTaskState();
}

class _LearnCardTaskState extends State<LearnCardTask> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onChanged(const TaskDraft(canSubmit: true, payload: true));
    });
  }

  @override
  Widget build(BuildContext context) {
    final explanation = widget.task.content['explanation']?.toString() ?? '';
    final items = widget.task.content['items'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.task.title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: ThingualSpacing.md),
        ThingualCard(
          padding: const EdgeInsets.all(ThingualSpacing.lg),
          child: Text(
            explanation,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: ThingualSpacing.lg),
        if (items is List)
          ...items.map((e) {
            final map = e is Map ? e : null;
            final phrase = map?['phrase']?.toString() ?? '';
            final note = map?['note']?.toString() ?? '';

            return Padding(
              padding: const EdgeInsets.only(bottom: ThingualSpacing.md),
              child: ThingualCard(
                padding: const EdgeInsets.all(ThingualSpacing.lg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: ThingualColors.deepIndigo.withValues(
                          alpha: 0.10,
                        ),
                        borderRadius: BorderRadius.circular(ThingualRadius.md),
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline,
                        color: ThingualColors.deepIndigo,
                      ),
                    ),
                    const SizedBox(width: ThingualSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            phrase,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: ThingualSpacing.xs),
                          Text(
                            note,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

class McqTask extends StatefulWidget {
  final LessonTask task;
  final bool isSubmitted;
  final DraftChanged onChanged;

  const McqTask({
    required this.task,
    required this.isSubmitted,
    required this.onChanged,
    super.key,
  });

  @override
  State<McqTask> createState() => _McqTaskState();
}

class _McqTaskState extends State<McqTask> {
  int? _selectedIndex;

  @override
  void didUpdateWidget(covariant McqTask oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.taskId != widget.task.taskId) {
      _selectedIndex = null;
      widget.onChanged(const TaskDraft(canSubmit: false, payload: null));
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.task.content['question']?.toString() ?? '';
    final options = widget.task.content['options'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.task.title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: ThingualSpacing.md),
        ThingualCard(
          padding: const EdgeInsets.all(ThingualSpacing.lg),
          child: Text(
            question,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: ThingualSpacing.lg),
        if (options is List)
          ...List.generate(options.length, (index) {
            final option = options[index].toString();
            return Padding(
              padding: const EdgeInsets.only(bottom: ThingualSpacing.md),
              child: _OptionTile(
                text: option,
                isSelected: _selectedIndex == index,
                isEnabled: !widget.isSubmitted,
                onTap: () {
                  if (widget.isSubmitted) return;
                  setState(() => _selectedIndex = index);
                  widget.onChanged(TaskDraft(canSubmit: true, payload: index));
                },
              ),
            );
          }),
      ],
    );
  }
}

class ScenarioMcqTask extends StatelessWidget {
  final LessonTask task;
  final bool isSubmitted;
  final DraftChanged onChanged;

  const ScenarioMcqTask({
    required this.task,
    required this.isSubmitted,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scenario = task.content['scenario']?.toString() ?? '';
    final question = task.content['question']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: ThingualSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(ThingualSpacing.lg),
          decoration: BoxDecoration(
            gradient: ThingualColors.primaryGradient,
            borderRadius: BorderRadius.circular(ThingualRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Scenario',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: ThingualSpacing.sm),
              Text(
                scenario,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: ThingualSpacing.lg),
        McqTask(
          task: LessonTask(
            taskId: task.taskId,
            order: task.order,
            type: 'mcq',
            category: task.category,
            title: question.isEmpty ? task.title : question,
            content: {
              'question': question,
              'options': task.content['options'],
              'correct_index': task.content['correct_index'],
              'explanation': task.content['explanation'],
            },
          ),
          isSubmitted: isSubmitted,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class FillBlankTask extends StatefulWidget {
  final LessonTask task;
  final bool isSubmitted;
  final DraftChanged onChanged;

  const FillBlankTask({
    required this.task,
    required this.isSubmitted,
    required this.onChanged,
    super.key,
  });

  @override
  State<FillBlankTask> createState() => _FillBlankTaskState();
}

class _FillBlankTaskState extends State<FillBlankTask> {
  String? _selected;

  @override
  void didUpdateWidget(covariant FillBlankTask oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.taskId != widget.task.taskId) {
      _selected = null;
      widget.onChanged(const TaskDraft(canSubmit: false, payload: null));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sentence = widget.task.content['sentence']?.toString() ?? '';
    final options = widget.task.content['options'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.task.title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: ThingualSpacing.md),
        ThingualCard(
          padding: const EdgeInsets.all(ThingualSpacing.lg),
          child: Text(
            sentence,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: ThingualSpacing.lg),
        if (options is List)
          Wrap(
            spacing: ThingualSpacing.sm,
            runSpacing: ThingualSpacing.sm,
            children: options.map((e) {
              final value = e.toString();
              final isSelected = _selected == value;
              return ChoiceChip(
                label: Text(value),
                selected: isSelected,
                onSelected: widget.isSubmitted
                    ? null
                    : (selected) {
                        setState(() => _selected = selected ? value : null);
                        widget.onChanged(
                          TaskDraft(
                            canSubmit: _selected != null,
                            payload: _selected,
                          ),
                        );
                      },
                selectedColor: ThingualColors.deepIndigo.withValues(
                  alpha: 0.12,
                ),
                side: BorderSide(
                  color: isSelected
                      ? ThingualColors.deepIndigo
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class MatchPairsTask extends StatefulWidget {
  final LessonTask task;
  final bool isSubmitted;
  final DraftChanged onChanged;

  const MatchPairsTask({
    required this.task,
    required this.isSubmitted,
    required this.onChanged,
    super.key,
  });

  @override
  State<MatchPairsTask> createState() => _MatchPairsTaskState();
}

class _MatchPairsTaskState extends State<MatchPairsTask> {
  String? _selectedPrompt;
  final Map<String, String> _matches = {};
  late List<String> _prompts;
  late List<String> _answers;

  void _loadPairs() {
    final pairsRaw = widget.task.content['pairs'];

    final prompts = <String>[];
    final answers = <String>[];
    if (pairsRaw is List) {
      for (final item in pairsRaw) {
        if (item is Map) {
          final p = item['prompt']?.toString();
          final a = item['answer']?.toString();
          if (p != null) prompts.add(p);
          if (a != null) answers.add(a);
        }
      }
    }

    _prompts = prompts;
    _answers = answers;
  }

  void _emitDraft() {
    final canSubmit = _matches.length == _prompts.length && _prompts.isNotEmpty;
    widget.onChanged(
      TaskDraft(
        canSubmit: canSubmit,
        payload: Map<String, String>.from(_matches),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadPairs();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onChanged(const TaskDraft(canSubmit: false, payload: null));
    });
  }

  @override
  void didUpdateWidget(covariant MatchPairsTask oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.taskId != widget.task.taskId) {
      _selectedPrompt = null;
      _matches.clear();
      _loadPairs();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onChanged(const TaskDraft(canSubmit: false, payload: null));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final instruction = widget.task.content['instruction']?.toString() ?? '';
    final unmatchedAnswers = _answers
        .where((a) => !_matches.values.contains(a))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.task.title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (instruction.isNotEmpty) ...[
          const SizedBox(height: ThingualSpacing.md),
          Text(
            instruction,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: ThingualSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prompts',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: ThingualSpacing.sm),
                  ..._prompts.map((p) {
                    final isMatched = _matches.containsKey(p);
                    final isSelected = _selectedPrompt == p;

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: ThingualSpacing.sm,
                      ),
                      child: _ChipTile(
                        label: p,
                        isSelected: isSelected,
                        isDisabled: widget.isSubmitted,
                        trailing: isMatched
                            ? const Icon(
                                Icons.check,
                                size: 18,
                                color: Colors.green,
                              )
                            : null,
                        onTap: () {
                          if (widget.isSubmitted) return;
                          if (isMatched) {
                            setState(() {
                              _matches.remove(p);
                              _selectedPrompt = null;
                            });
                            _emitDraft();
                            return;
                          }
                          setState(() => _selectedPrompt = p);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(width: ThingualSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Answers',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: ThingualSpacing.sm),
                  ...unmatchedAnswers.map((a) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: ThingualSpacing.sm,
                      ),
                      child: _ChipTile(
                        label: a,
                        isSelected: false,
                        isDisabled:
                            widget.isSubmitted || _selectedPrompt == null,
                        onTap: () {
                          if (widget.isSubmitted) return;
                          if (_selectedPrompt == null) return;

                          setState(() {
                            _matches[_selectedPrompt!] = a;
                            _selectedPrompt = null;
                          });
                          _emitDraft();
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: ThingualSpacing.lg),
        if (_matches.isNotEmpty)
          ThingualCard(
            padding: const EdgeInsets.all(ThingualSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Matches',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: ThingualSpacing.sm),
                ..._matches.entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: ThingualSpacing.sm),
                    child: Row(
                      children: [
                        Expanded(child: Text(e.key)),
                        const Icon(Icons.arrow_right_alt, size: 18),
                        Expanded(child: Text(e.value)),
                      ],
                    ),
                  );
                }),
                if (!widget.isSubmitted)
                  Text(
                    'Tap a matched prompt to undo.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class SortWordsTask extends StatefulWidget {
  final LessonTask task;
  final bool isSubmitted;
  final DraftChanged onChanged;

  const SortWordsTask({
    required this.task,
    required this.isSubmitted,
    required this.onChanged,
    super.key,
  });

  @override
  State<SortWordsTask> createState() => _SortWordsTaskState();
}

class _SortWordsTaskState extends State<SortWordsTask> {
  late List<String> _pool;
  final List<String> _selected = [];

  void _loadPool() {
    final wordsRaw = widget.task.content['words'];
    final pool = <String>[];
    if (wordsRaw is List) {
      for (final w in wordsRaw) {
        pool.add(w.toString());
      }
    }
    _pool = pool;
  }

  void _emitDraft() {
    final canSubmit = _selected.isNotEmpty;
    widget.onChanged(
      TaskDraft(canSubmit: canSubmit, payload: List<String>.from(_selected)),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadPool();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onChanged(const TaskDraft(canSubmit: false, payload: null));
    });
  }

  @override
  void didUpdateWidget(covariant SortWordsTask oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.taskId != widget.task.taskId) {
      _selected.clear();
      _loadPool();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onChanged(const TaskDraft(canSubmit: false, payload: null));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final instruction = widget.task.content['instruction']?.toString() ?? '';
    final remaining = _pool.where((w) => !_selected.contains(w)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.task.title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (instruction.isNotEmpty) ...[
          const SizedBox(height: ThingualSpacing.md),
          Text(
            instruction,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: ThingualSpacing.lg),
        ThingualCard(
          padding: const EdgeInsets.all(ThingualSpacing.lg),
          child: Wrap(
            spacing: ThingualSpacing.sm,
            runSpacing: ThingualSpacing.sm,
            children: _selected.isEmpty
                ? [
                    Text(
                      'Tap words below to build the sentence.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ]
                : _selected
                      .map(
                        (w) => InputChip(
                          label: Text(w),
                          onDeleted: widget.isSubmitted
                              ? null
                              : () {
                                  setState(() => _selected.remove(w));
                                  _emitDraft();
                                },
                        ),
                      )
                      .toList(),
          ),
        ),
        const SizedBox(height: ThingualSpacing.lg),
        Wrap(
          spacing: ThingualSpacing.sm,
          runSpacing: ThingualSpacing.sm,
          children: remaining
              .map(
                (w) => ActionChip(
                  label: Text(w),
                  onPressed: widget.isSubmitted
                      ? null
                      : () {
                          setState(() => _selected.add(w));
                          _emitDraft();
                        },
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class ErrorCorrectionTask extends StatelessWidget {
  final LessonTask task;
  final bool isSubmitted;
  final DraftChanged onChanged;

  const ErrorCorrectionTask({
    required this.task,
    required this.isSubmitted,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final instruction = task.content['instruction']?.toString() ?? '';
    final wrong = task.content['wrong_sentence']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (instruction.isNotEmpty) ...[
          const SizedBox(height: ThingualSpacing.md),
          Text(
            instruction,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (wrong.isNotEmpty) ...[
          const SizedBox(height: ThingualSpacing.lg),
          ThingualCard(
            padding: const EdgeInsets.all(ThingualSpacing.lg),
            backgroundColor: Colors.red.withValues(alpha: 0.06),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: ThingualSpacing.md),
                Expanded(
                  child: Text(
                    wrong,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: ThingualSpacing.lg),
        McqTask(task: task, isSubmitted: isSubmitted, onChanged: onChanged),
      ],
    );
  }
}

class ListenRepeatTask extends StatefulWidget {
  final LessonTask task;
  final bool isSubmitted;
  final DraftChanged onChanged;

  const ListenRepeatTask({
    required this.task,
    required this.isSubmitted,
    required this.onChanged,
    super.key,
  });

  @override
  State<ListenRepeatTask> createState() => _ListenRepeatTaskState();
}

class _ListenRepeatTaskState extends State<ListenRepeatTask> {
  bool _done = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onChanged(const TaskDraft(canSubmit: false, payload: false));
    });
  }

  @override
  void didUpdateWidget(covariant ListenRepeatTask oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.taskId != widget.task.taskId) {
      _done = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onChanged(const TaskDraft(canSubmit: false, payload: false));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final instruction = widget.task.content['instruction']?.toString() ?? '';
    final phrasesRaw = widget.task.content['phrases'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.task.title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (instruction.isNotEmpty) ...[
          const SizedBox(height: ThingualSpacing.md),
          Text(
            instruction,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: ThingualSpacing.lg),
        if (phrasesRaw is List)
          ...phrasesRaw.map((e) {
            final map = e is Map ? e : null;
            final text = map?['text']?.toString() ?? '';

            return Padding(
              padding: const EdgeInsets.only(bottom: ThingualSpacing.md),
              child: ThingualCard(
                padding: const EdgeInsets.all(ThingualSpacing.lg),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Play audio (placeholder)',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Audio playback coming soon.'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.volume_up),
                    ),
                    const SizedBox(width: ThingualSpacing.sm),
                    Expanded(
                      child: Text(
                        text,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: ThingualSpacing.sm),
        ThingualCard(
          padding: const EdgeInsets.all(ThingualSpacing.md),
          child: Row(
            children: [
              Checkbox(
                value: _done,
                onChanged: widget.isSubmitted
                    ? null
                    : (value) {
                        setState(() => _done = value ?? false);
                        widget.onChanged(
                          TaskDraft(canSubmit: _done, payload: _done),
                        );
                      },
              ),
              const SizedBox(width: ThingualSpacing.sm),
              Expanded(
                child: Text(
                  'I repeated these phrases aloud.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SpeakingTask extends StatefulWidget {
  final LessonTask task;
  final bool isSubmitted;
  final DraftChanged onChanged;

  const SpeakingTask({
    required this.task,
    required this.isSubmitted,
    required this.onChanged,
    super.key,
  });

  @override
  State<SpeakingTask> createState() => _SpeakingTaskState();
}

class _SpeakingTaskState extends State<SpeakingTask> {
  late final TextEditingController _controller;

  void _emitDraft() {
    final minWords = (widget.task.content['min_words'] as num?)?.toInt() ?? 0;
    final text = _controller.text;
    final words = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.trim().isNotEmpty)
        .toList();
    final canSubmit = minWords <= 0
        ? text.trim().isNotEmpty
        : words.length >= minWords;
    widget.onChanged(TaskDraft(canSubmit: canSubmit, payload: text));
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_emitDraft);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _emitDraft();
    });
  }

  @override
  void didUpdateWidget(covariant SpeakingTask oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.taskId != widget.task.taskId) {
      _controller.removeListener(_emitDraft);
      _controller.text = '';
      _controller.addListener(_emitDraft);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onChanged(const TaskDraft(canSubmit: false, payload: ''));
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_emitDraft);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final instruction = widget.task.content['instruction']?.toString() ?? '';
    final prompt = widget.task.content['prompt']?.toString() ?? '';
    final keyPhrasesRaw = widget.task.content['key_phrases'];
    final minWords = (widget.task.content['min_words'] as num?)?.toInt() ?? 0;

    final text = _controller.text;
    final words = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.trim().isNotEmpty)
        .toList();

    final canSubmit = minWords <= 0
        ? text.trim().isNotEmpty
        : words.length >= minWords;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.task.title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (instruction.isNotEmpty) ...[
          const SizedBox(height: ThingualSpacing.md),
          Text(
            instruction,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (prompt.isNotEmpty) ...[
          const SizedBox(height: ThingualSpacing.lg),
          ThingualCard(
            padding: const EdgeInsets.all(ThingualSpacing.lg),
            child: Text(
              prompt,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
        const SizedBox(height: ThingualSpacing.lg),
        Row(
          children: [
            IconButton(
              tooltip: 'Microphone (placeholder)',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Microphone capture coming soon.'),
                  ),
                );
              },
              icon: const Icon(Icons.mic_none),
            ),
            const SizedBox(width: ThingualSpacing.sm),
            Expanded(
              child: Text(
                'Type your response (text fallback).',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Text(
              minWords > 0
                  ? '${words.length}/$minWords words'
                  : '${words.length} words',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: canSubmit ? Colors.green : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: ThingualSpacing.sm),
        TextField(
          controller: _controller,
          enabled: !widget.isSubmitted,
          minLines: 3,
          maxLines: 6,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: 'Write your response here…',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ThingualRadius.md),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        if (keyPhrasesRaw is List && keyPhrasesRaw.isNotEmpty) ...[
          const SizedBox(height: ThingualSpacing.lg),
          Text(
            'Key phrases',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: ThingualSpacing.sm),
          Wrap(
            spacing: ThingualSpacing.sm,
            runSpacing: ThingualSpacing.sm,
            children: keyPhrasesRaw
                .map(
                  (e) => Chip(
                    label: Text(e.toString()),
                    backgroundColor: ThingualColors.vivdCyan.withValues(
                      alpha: 0.10,
                    ),
                    side: BorderSide(
                      color: ThingualColors.vivdCyan.withValues(alpha: 0.30),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class LessonSummaryTask extends StatefulWidget {
  final LessonTask task;
  final bool isSubmitted;
  final DraftChanged onChanged;

  const LessonSummaryTask({
    required this.task,
    required this.isSubmitted,
    required this.onChanged,
    super.key,
  });

  @override
  State<LessonSummaryTask> createState() => _LessonSummaryTaskState();
}

class _LessonSummaryTaskState extends State<LessonSummaryTask> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onChanged(const TaskDraft(canSubmit: true, payload: true));
    });
  }

  @override
  Widget build(BuildContext context) {
    final learned = widget.task.content['what_you_learned'];
    final nextTitle = widget.task.content['next_lesson_title']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.task.title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: ThingualSpacing.md),
        ThingualCard(
          padding: const EdgeInsets.all(ThingualSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What you learned',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: ThingualSpacing.sm),
              if (learned is List)
                ...learned.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: ThingualSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 18,
                          color: Colors.green,
                        ),
                        const SizedBox(width: ThingualSpacing.sm),
                        Expanded(child: Text(e.toString())),
                      ],
                    ),
                  ),
                ),
              if (nextTitle != null && nextTitle.isNotEmpty) ...[
                const SizedBox(height: ThingualSpacing.md),
                Text(
                  'Up next: $nextTitle',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: ThingualColors.deepIndigo,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  const _OptionTile({
    required this.text,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderColor = isSelected
        ? ThingualColors.deepIndigo
        : (isDark ? Colors.white.withValues(alpha: 0.10) : Colors.grey[200]!);

    final bgColor = isSelected
        ? ThingualColors.deepIndigo.withValues(alpha: isDark ? 0.20 : 0.08)
        : (isDark ? ThingualColors.darkSurface : Colors.white);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(ThingualRadius.lg),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(ThingualRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(ThingualSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ThingualRadius.lg),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: ThingualColors.deepIndigo,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDisabled;
  final Widget? trailing;
  final VoidCallback onTap;

  const _ChipTile({
    required this.label,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isSelected
          ? ThingualColors.deepIndigo.withValues(alpha: isDark ? 0.22 : 0.10)
          : (isDark ? ThingualColors.darkSurface : Colors.white),
      borderRadius: BorderRadius.circular(ThingualRadius.md),
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(ThingualRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ThingualSpacing.md,
            vertical: ThingualSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ThingualRadius.md),
            border: Border.all(
              color: isSelected
                  ? ThingualColors.deepIndigo
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.10)
                        : Colors.grey[200]!),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              ...?((trailing == null) ? null : <Widget>[trailing!]),
            ],
          ),
        ),
      ),
    );
  }
}
