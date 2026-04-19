import 'package:flutter/material.dart';

import '../../../core/constants/brand_colors.dart';
import '../../../core/constants/theme.dart';
import '../../../shared/widgets/thingual_widgets.dart';
import '../models/lesson_models.dart';

class LessonStartSheet extends StatelessWidget {
  final LessonDefinition lesson;
  final VoidCallback onStart;

  const LessonStartSheet({
    required this.lesson,
    required this.onStart,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(ThingualSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: ThingualSpacing.lg),
            Text(
              lesson.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: ThingualSpacing.sm),
            Text(
              lesson.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.72)
                        : ThingualColors.ink.withValues(alpha: 0.72),
                  ),
            ),
            const SizedBox(height: ThingualSpacing.lg),
            Row(
              children: [
                _Pill(
                  icon: Icons.schedule,
                  label: '${lesson.estimatedMinutes} min',
                ),
                const SizedBox(width: ThingualSpacing.sm),
                _Pill(
                  icon: Icons.bolt,
                  label: '${lesson.xpReward} XP',
                  accent: ThingualColors.amber,
                ),
                const SizedBox(width: ThingualSpacing.sm),
                _Pill(
                  icon: Icons.list_alt,
                  label: '${lesson.tasks.length} tasks',
                ),
              ],
            ),
            const SizedBox(height: ThingualSpacing.xl),
            ThingualCard(
              padding: const EdgeInsets.all(ThingualSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lesson flow',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: ThingualSpacing.sm),
                  Text(
                    'One task at a time. Submit your answer to see feedback, then continue.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ThingualSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ThingualButton(
                label: 'Start Lesson',
                icon: Icons.play_arrow,
                onPressed: onStart,
              ),
            ),
            const SizedBox(height: ThingualSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: ThingualButton(
                label: 'Not now',
                icon: Icons.close,
                isOutlined: true,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? accent;

  const _Pill({
    required this.icon,
    required this.label,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = accent ?? ThingualColors.vivdCyan;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThingualSpacing.md,
        vertical: ThingualSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : color.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: ThingualSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
