import 'package:flutter/material.dart';
import '../../../core/constants/brand_colors.dart';
import '../../../core/constants/theme.dart';
import '../../../shared/widgets/thingual_widgets.dart';
import '../../lessons/models/lesson_models.dart';
import '../../lessons/progress/lesson_progress_repository.dart';
import '../../lessons/screens/lesson_player_screen.dart';
import '../../lessons/screens/lesson_start_sheet.dart';
import '../../lessons/services/lesson_loader.dart';

enum _LessonStatus { completed, active, unlocked, locked }

class _LessonNode {
  final int lessonNumber;
  final String lessonId;
  final String title;
  final String type;
  final _LessonStatus status;

  _LessonNode({
    required this.lessonNumber,
    required this.lessonId,
    required this.title,
    required this.type,
    required this.status,
  });

  _LessonNode copyWith({_LessonStatus? status, String? title, String? type}) {
    return _LessonNode(
      lessonNumber: lessonNumber,
      lessonId: lessonId,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
    );
  }
}

class _FutureUnit {
  final int unitNumber;
  final String title;
  final String level;

  _FutureUnit({
    required this.unitNumber,
    required this.title,
    required this.level,
  });
}

class LearningPathPage extends StatefulWidget {
  const LearningPathPage({super.key});

  @override
  State<LearningPathPage> createState() => _LearningPathPageState();
}

class _LearningPathPageState extends State<LearningPathPage> {
  List<_LessonNode> _lessons = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    LessonProgressRepository.instance.revision.addListener(_refreshProgress);
    _init();
  }

  @override
  void dispose() {
    LessonProgressRepository.instance.revision.removeListener(_refreshProgress);
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final meta = await LessonLoader.instance.loadUnit1LessonMetadata();
      if (!mounted) return;

      final nodes = meta.map(_nodeFromMeta).toList();
      setState(() {
        _lessons = nodes;
        _isLoading = false;
      });

      await _refreshProgress();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _lessons = const [];
        _isLoading = false;
      });
    }
  }

  _LessonNode _nodeFromMeta(LessonDefinition meta) {
    return _LessonNode(
      lessonNumber: meta.lessonNumber,
      lessonId: meta.lessonId,
      title: meta.title,
      type: meta.lessonNumber == 8 ? 'QUIZ' : 'LESSON',
      status: _LessonStatus.locked,
    );
  }

  Future<void> _refreshProgress() async {
    if (_lessons.isEmpty) return;

    final all = await LessonProgressRepository.instance.loadAll();
    if (!mounted) return;

    final completed = <String>{
      for (final entry in all.entries)
        if (entry.value.lessonCompleted) entry.key,
    };

    final ordered = [..._lessons]
      ..sort((a, b) => a.lessonNumber.compareTo(b.lessonNumber));

    int? firstIncompleteIndex;
    for (var i = 0; i < ordered.length; i++) {
      if (!completed.contains(ordered[i].lessonId)) {
        firstIncompleteIndex = i;
        break;
      }
    }

    final updated = <_LessonNode>[];
    for (var i = 0; i < ordered.length; i++) {
      final node = ordered[i];
      if (completed.contains(node.lessonId)) {
        updated.add(node.copyWith(status: _LessonStatus.completed));
      } else if (firstIncompleteIndex == i) {
        updated.add(node.copyWith(status: _LessonStatus.active));
      } else if (firstIncompleteIndex != null && i < firstIncompleteIndex) {
        updated.add(node.copyWith(status: _LessonStatus.unlocked));
      } else {
        updated.add(node.copyWith(status: _LessonStatus.locked));
      }
    }

    setState(() {
      _lessons = updated;
    });
  }

  final List<_FutureUnit> _futureUnits = [
    _FutureUnit(
      unitNumber: 2,
      title: 'Numbers, Colors & Descriptions',
      level: 'A1-A2',
    ),
    _FutureUnit(unitNumber: 3, title: 'Daily Routines & Time', level: 'A2'),
    _FutureUnit(unitNumber: 4, title: 'Food, Shopping & Likes', level: 'A2'),
    _FutureUnit(
      unitNumber: 5,
      title: 'Family & Describing People',
      level: 'A2-B1',
    ),
  ];

  Future<void> _onLessonTap(_LessonNode lesson) async {
    if (lesson.status == _LessonStatus.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete previous lessons to unlock this lesson'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    LessonDefinition loaded;
    try {
      loaded = await LessonLoader.instance.loadUnit1Lesson(lesson.lessonId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not load lesson: $e')));
      return;
    }

    if (!mounted) return;

    final start = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? ThingualColors.darkBg : ThingualColors.cloud,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(ThingualRadius.xl),
            ),
          ),
          child: LessonStartSheet(
            lesson: loaded,
            onStart: () => Navigator.of(context).pop(true),
          ),
        );
      },
    );

    if (start != true || !mounted) return;

    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => LessonPlayerScreen(lessonId: lesson.lessonId),
      ),
    );

    if (completed == true) {
      await _refreshProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (_isLoading) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.all(
          isMobile ? ThingualSpacing.lg : ThingualSpacing.xl,
        ),
        children: [
          // Header with title and notification
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Learning Path',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(ThingualSpacing.md),
                decoration: BoxDecoration(
                  color: ThingualColors.deepIndigo.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ThingualRadius.md),
                ),
                child: const Icon(
                  Icons.notifications_none,
                  color: ThingualColors.deepIndigo,
                ),
              ),
            ],
          ),
          const SizedBox(height: ThingualSpacing.xl),

          // Hero Card - AI Personalized Curriculum
          _HeroCard(),
          const SizedBox(height: ThingualSpacing.xl),

          // Overall Progress Card
          _ProgressCard(
            completed: _lessons
                .where((l) => l.status == _LessonStatus.completed)
                .length,
            total: _lessons.isEmpty ? 1 : _lessons.length,
          ),
          const SizedBox(height: ThingualSpacing.xl),

          // Current Unit Card
          _CurrentUnitCard(
            completedCount: _lessons
                .where((l) => l.status == _LessonStatus.completed)
                .length,
            totalCount: _lessons.length,
          ),
          const SizedBox(height: ThingualSpacing.xl),

          // Lesson Timeline
          SectionHeader(title: 'Your Journey'),
          const SizedBox(height: ThingualSpacing.lg),
          _LessonTimeline(lessons: _lessons, onLessonTap: _onLessonTap),
          const SizedBox(height: ThingualSpacing.xl),

          // Future Units
          SectionHeader(title: 'Upcoming Units'),
          const SizedBox(height: ThingualSpacing.lg),
          Column(
            children: List.generate(
              _futureUnits.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: ThingualSpacing.lg),
                child: _LockedUnitCard(unit: _futureUnits[index]),
              ),
            ),
          ),
          const SizedBox(height: ThingualSpacing.xxxl),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThingualSpacing.xl),
      decoration: BoxDecoration(
        gradient: ThingualColors.primaryGradient,
        borderRadius: BorderRadius.circular(ThingualRadius.lg),
        boxShadow: [
          BoxShadow(
            color: ThingualColors.deepIndigo.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThingualBadge(
            label: 'AI PERSONALIZED',
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            textColor: Colors.white,
          ),
          const SizedBox(height: ThingualSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A1 English Journey',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: ThingualSpacing.sm),
                    Text(
                      'Tailored to Your Interests',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: ThingualSpacing.lg),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ThingualSpacing.lg,
                  vertical: ThingualSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(ThingualRadius.md),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'A1',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'CEFR LEVEL',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int completed;
  final int total;

  const _ProgressCard({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = total <= 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);
    final pct = (progress * 100).round();

    return ThingualCard(
      padding: const EdgeInsets.all(ThingualSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'OVERALL PROGRESS',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '$pct%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: ThingualColors.deepIndigo,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: ThingualSpacing.md),
          ThingualProgressBar(
            progress: progress,
            color: ThingualColors.deepIndigo,
          ),
        ],
      ),
    );
  }
}

class _CurrentUnitCard extends StatelessWidget {
  final int completedCount;
  final int totalCount;

  const _CurrentUnitCard({
    required this.completedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThingualSpacing.lg),
      decoration: BoxDecoration(
        gradient: ThingualColors.primaryGradient,
        borderRadius: BorderRadius.circular(ThingualRadius.lg),
        boxShadow: [
          BoxShadow(
            color: ThingualColors.deepIndigo.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UNIT 1 • A1',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: ThingualSpacing.sm),
                    Text(
                      'First Steps in English',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: ThingualSpacing.xs),
                    Text(
                      'Greetings to Daily Life — master the core of everyday English.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: ThingualSpacing.md),
              ThingualBadge(
                label: '$completedCount/$totalCount done',
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                textColor: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: ThingualSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(ThingualRadius.full),
            child: LinearProgressIndicator(
              value: completedCount / totalCount,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonTimeline extends StatelessWidget {
  final List<_LessonNode> lessons;
  final Function(_LessonNode) onLessonTap;

  const _LessonTimeline({required this.lessons, required this.onLessonTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(lessons.length, (index) {
        final lesson = lessons[index];
        final isLast = index == lessons.length - 1;

        return Column(
          children: [
            _LessonNodeWidget(lesson: lesson, onTap: () => onLessonTap(lesson)),
            if (!isLast)
              SizedBox(
                height: 60,
                child: Center(
                  child: Container(
                    width: 3,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _LessonNodeWidget extends StatefulWidget {
  final _LessonNode lesson;
  final VoidCallback onTap;

  const _LessonNodeWidget({required this.lesson, required this.onTap});

  @override
  State<_LessonNodeWidget> createState() => _LessonNodeWidgetState();
}

class _LessonNodeWidgetState extends State<_LessonNodeWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;

  @override
  void initState() {
    super.initState();
    _syncPulseController();
  }

  @override
  void didUpdateWidget(covariant _LessonNodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lesson.status != widget.lesson.status) {
      _syncPulseController();
    }
  }

  void _syncPulseController() {
    final shouldPulse = widget.lesson.status == _LessonStatus.active;

    if (shouldPulse) {
      _pulseController ??= AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      )..repeat(reverse: true);
    } else {
      _pulseController?.dispose();
      _pulseController = null;
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ThingualSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Node Circle
          Stack(
            alignment: Alignment.center,
            children: [
              if (widget.lesson.status == _LessonStatus.active)
                AnimatedBuilder(
                  animation: _pulseController!,
                  builder: (context, child) {
                    return Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ThingualColors.deepIndigo.withValues(
                          alpha: 0.1 * (1 - _pulseController!.value),
                        ),
                      ),
                    );
                  },
                ),
              GestureDetector(
                onTap: widget.onTap,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getNodeColor(widget.lesson.status),
                    boxShadow: widget.lesson.status == _LessonStatus.active
                        ? [
                            BoxShadow(
                              color: ThingualColors.deepIndigo.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(child: _getNodeIcon(widget.lesson.status)),
                ),
              ),
            ],
          ),
          const SizedBox(width: ThingualSpacing.lg),
          // Lesson Label Card
          Expanded(
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                padding: const EdgeInsets.all(ThingualSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? ThingualColors.darkSurface : Colors.white,
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.07)
                        : Colors.grey[200]!,
                  ),
                  borderRadius: BorderRadius.circular(ThingualRadius.md),
                  boxShadow: !isDark
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.lesson.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: ThingualSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ThingualBadge(
                          label: widget.lesson.type,
                          backgroundColor: _getBadgeColor(widget.lesson.status),
                          textColor: _getBadgeTextColor(widget.lesson.status),
                        ),
                        if (widget.lesson.status == _LessonStatus.active)
                          SizedBox(
                            height: 28,
                            child: ElevatedButton.icon(
                              onPressed: widget.onTap,
                              icon: const Icon(Icons.play_arrow, size: 14),
                              label: const Text('START'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: ThingualSpacing.md,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getNodeColor(_LessonStatus status) {
    switch (status) {
      case _LessonStatus.completed:
        return Colors.green;
      case _LessonStatus.active:
        return ThingualColors.deepIndigo;
      case _LessonStatus.unlocked:
        return Colors.orange;
      case _LessonStatus.locked:
        return Colors.grey[400]!;
    }
  }

  Widget _getNodeIcon(_LessonStatus status) {
    switch (status) {
      case _LessonStatus.completed:
        return const Icon(Icons.check, color: Colors.white, size: 28);
      case _LessonStatus.active:
        return const Icon(Icons.play_arrow, color: Colors.white, size: 28);
      case _LessonStatus.unlocked:
        return const Icon(Icons.lock_open, color: Colors.white, size: 24);
      case _LessonStatus.locked:
        return const Icon(Icons.lock, color: Colors.white, size: 24);
    }
  }

  Color _getBadgeColor(_LessonStatus status) {
    switch (status) {
      case _LessonStatus.completed:
        return Colors.green.withValues(alpha: 0.1);
      case _LessonStatus.active:
        return ThingualColors.deepIndigo.withValues(alpha: 0.1);
      case _LessonStatus.unlocked:
        return Colors.orange.withValues(alpha: 0.1);
      case _LessonStatus.locked:
        return Colors.grey[300]!;
    }
  }

  Color _getBadgeTextColor(_LessonStatus status) {
    switch (status) {
      case _LessonStatus.completed:
        return Colors.green;
      case _LessonStatus.active:
        return ThingualColors.deepIndigo;
      case _LessonStatus.unlocked:
        return Colors.orange;
      case _LessonStatus.locked:
        return Colors.grey[600]!;
    }
  }
}

class _LockedUnitCard extends StatelessWidget {
  final _FutureUnit unit;

  const _LockedUnitCard({required this.unit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThingualSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[400]!, Colors.grey[500]!],
        ),
        borderRadius: BorderRadius.circular(ThingualRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(ThingualSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(ThingualRadius.md),
            ),
            child: const Icon(Icons.lock, color: Colors.white, size: 20),
          ),
          const SizedBox(width: ThingualSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UNIT ${unit.unitNumber}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: ThingualSpacing.xs),
                Text(
                  unit.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: ThingualSpacing.sm),
                Text(
                  'Complete previous unit to unlock this unit',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: ThingualSpacing.md),
          ThingualBadge(
            label: 'LOCKED',
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
