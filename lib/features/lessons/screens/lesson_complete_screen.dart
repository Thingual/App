import 'package:flutter/material.dart';

import '../../../core/constants/brand_colors.dart';
import '../../../core/constants/theme.dart';
import '../../../shared/widgets/thingual_widgets.dart';
import '../progress/lesson_metrics.dart';

class LessonCompleteScreen extends StatelessWidget {
  final String lessonTitle;
  final LessonMetrics metrics;

  const LessonCompleteScreen({
    required this.lessonTitle,
    required this.metrics,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final accuracyPct = (metrics.accuracy * 100).round();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ThingualSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: ThingualSpacing.lg),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withValues(alpha: 0.12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 44,
                  ),
                ),
              ),
              const SizedBox(height: ThingualSpacing.lg),
              Text(
                'Great job!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: ThingualSpacing.sm),
              Text(
                'You completed $lessonTitle',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: ThingualSpacing.xl),
              ThingualCard(
                padding: const EdgeInsets.all(ThingualSpacing.lg),
                child: Column(
                  children: [
                    _MetricRow(
                      label: 'XP earned',
                      value: '${metrics.xpEarned}',
                      icon: Icons.bolt,
                      color: ThingualColors.amber,
                    ),
                    const SizedBox(height: ThingualSpacing.md),
                    _MetricRow(
                      label: 'Accuracy',
                      value: '$accuracyPct%',
                      icon: Icons.track_changes,
                      color: ThingualColors.deepIndigo,
                    ),
                    const SizedBox(height: ThingualSpacing.md),
                    _MetricRow(
                      label: 'Mistakes',
                      value: '${metrics.mistakes}',
                      icon: Icons.close,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ThingualButton(
                  label: 'Continue',
                  icon: Icons.arrow_forward,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(ThingualRadius.md),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: ThingualSpacing.md),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
      ],
    );
  }
}
