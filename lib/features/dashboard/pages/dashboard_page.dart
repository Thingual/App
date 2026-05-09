import 'package:flutter/material.dart';
import '../../../core/constants/brand_colors.dart';
import '../../../core/constants/theme.dart';
import '../../../shared/widgets/thingual_widgets.dart';
import '../../lessons/progress/lesson_progress_repository.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late DateTime _now;

  AggregatedProgress? _progress;
  double _overallAccuracy = 0;

  @override
  void dispose() {
    LessonProgressRepository.instance.revision.removeListener(_reloadProgress);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    LessonProgressRepository.instance.revision.addListener(_reloadProgress);
    _reloadProgress();
  }

  Future<void> _reloadProgress() async {
    final repo = LessonProgressRepository.instance;
    final all = await repo.loadAll();
    final aggregated = await repo.aggregate();

    var correct = 0;
    var total = 0;
    for (final m in all.values) {
      correct += m.correctAnswers;
      total += m.totalScoredAnswers;
    }

    if (!mounted) return;
    setState(() {
      _progress = aggregated;
      _overallAccuracy = total == 0 ? 0 : (correct / total);
    });
  }

  String _getGreeting() {
    final hour = _now.hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    final progress = _progress;
    final accuracyPct = (_overallAccuracy * 100).round();
    final totalXp = progress?.totalXp ?? 0;
    final lessonsCompleted = progress?.lessonsCompleted ?? 0;

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.all(
          isMobile ? ThingualSpacing.lg : ThingualSpacing.xl,
        ),
        children: [
          // Greeting Section
          GreetingCard(greeting: _getGreeting(), userName: 'Alex'),
          const SizedBox(height: ThingualSpacing.xl),

          // Streak Banner
          ThingualCard(
            padding: const EdgeInsets.all(ThingualSpacing.xl),
            backgroundColor: ThingualColors.deepIndigo.withValues(alpha: 0.1),
            border: Border.all(
              color: ThingualColors.deepIndigo.withValues(alpha: 0.3),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(ThingualSpacing.lg),
                  decoration: BoxDecoration(
                    color: ThingualColors.deepIndigo.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(ThingualRadius.md),
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: ThingualColors.deepIndigo,
                    size: 28,
                  ),
                ),
                const SizedBox(width: ThingualSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '0-Day Streak',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: ThingualColors.deepIndigo,
                        ),
                      ),
                      const SizedBox(height: ThingualSpacing.xs),
                      Text(
                        'Keep learning to build your streak!',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Start'),
                ),
              ],
            ),
          ),
          const SizedBox(height: ThingualSpacing.xl),

          // Today's Focus
          SectionHeader(title: 'Today\'s Focus'),
          ThingualCard(
            padding: const EdgeInsets.all(ThingualSpacing.lg),
            onTap: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(ThingualSpacing.md),
                      decoration: BoxDecoration(
                        gradient: ThingualColors.primaryGradient,
                        borderRadius: BorderRadius.circular(ThingualRadius.md),
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: ThingualSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Conversational English',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'Unit 5 of 10',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    ThingualBadge(
                      label: 'A1',
                      backgroundColor: ThingualColors.amber.withValues(
                        alpha: 0.1,
                      ),
                      textColor: ThingualColors.amber,
                    ),
                  ],
                ),
                const SizedBox(height: ThingualSpacing.lg),
                Text(
                  'Progress',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: ThingualSpacing.sm),
                ThingualProgressBar(progress: 0.5),
                const SizedBox(height: ThingualSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '12 min',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Continue'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: ThingualSpacing.xl),

          // Stats
          SectionHeader(title: 'Your Stats'),
          ThingualTileGrid(
            children: [
              StatsCard(
                label: 'Accuracy',
                value: '$accuracyPct',
                unit: '%',
                icon: Icons.favorite,
                accentColor: ThingualColors.vivdCyan,
              ),
              StatsCard(
                label: 'XP Earned',
                value: '$totalXp',
                unit: 'xp',
                icon: Icons.bolt,
                accentColor: ThingualColors.amber,
              ),
              StatsCard(
                label: 'Lessons Done',
                value: '$lessonsCompleted',
                unit: 'lessons',
                icon: Icons.check_circle,
                accentColor: ThingualColors.deepIndigo,
              ),
            ],
          ),
          const SizedBox(height: ThingualSpacing.xl),

          // Up Next
          SectionHeader(title: 'Up Next'),
          if (isMobile)
            Column(
              children: [
                _UpNextCard(
                  title: 'Reviews Due',
                  subtitle: '5 vocabulary reviews waiting',
                  icon: Icons.refresh,
                  color: ThingualColors.vivdCyan,
                ),
                const SizedBox(height: ThingualSpacing.lg),
                _UpNextCard(
                  title: 'All Units',
                  subtitle: 'Continue with the next unit',
                  icon: Icons.list,
                  color: ThingualColors.deepIndigo,
                ),
              ],
            )
          else
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: ThingualSpacing.lg,
              mainAxisSpacing: ThingualSpacing.lg,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _UpNextCard(
                  title: 'Reviews Due',
                  subtitle: '5 vocabulary reviews waiting',
                  icon: Icons.refresh,
                  color: ThingualColors.vivdCyan,
                ),
                _UpNextCard(
                  title: 'All Units',
                  subtitle: 'Continue with the next unit',
                  icon: Icons.list,
                  color: ThingualColors.deepIndigo,
                ),
              ],
            ),
          const SizedBox(height: ThingualSpacing.xxxl),
        ],
      ),
    );
  }
}

class _UpNextCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _UpNextCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ThingualCard(
      onTap: () {},
      padding: const EdgeInsets.all(ThingualSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(ThingualSpacing.md),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ThingualRadius.md),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: ThingualSpacing.xs),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Icon(Icons.arrow_forward, color: color, size: 16),
          ),
        ],
      ),
    );
  }
}
