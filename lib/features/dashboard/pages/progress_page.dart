import 'package:flutter/material.dart';
import '../../../core/constants/brand_colors.dart';
import '../../../core/constants/theme.dart';
import '../../../shared/widgets/thingual_widgets.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.all(
          isMobile ? ThingualSpacing.lg : ThingualSpacing.xl,
        ),
        children: [
          // Current CEFR Level
          SectionHeader(title: 'Your Level'),
          ThingualCard(
            padding: const EdgeInsets.all(ThingualSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: ThingualColors.primaryGradient,
                  ),
                  child: Center(
                    child: Text(
                      'A1',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: ThingualSpacing.lg),
                Text(
                  'Beginner',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ThingualSpacing.md),
                Text(
                  'Elementary proficiency • Ready for A1 certification',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ThingualSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(ThingualSpacing.lg),
                  decoration: BoxDecoration(
                    color: ThingualColors.deepIndigo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(ThingualRadius.md),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Progress to A2',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: ThingualSpacing.md),
                      ThingualProgressBar(
                        progress: 0.35,
                        color: ThingualColors.vivdCyan,
                      ),
                      const SizedBox(height: ThingualSpacing.sm),
                      Text(
                        '35% complete',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ThingualSpacing.xl),

          // Stats
          SectionHeader(title: 'Key Metrics'),
          ThingualTileGrid(
            children: [
              StatsCard(
                label: 'Accuracy',
                value: '87',
                unit: '%',
                icon: Icons.favorite,
                accentColor: ThingualColors.vivdCyan,
              ),
              StatsCard(
                label: 'Words Known',
                value: '3,245',
                unit: 'words',
                icon: Icons.book,
                accentColor: ThingualColors.amber,
              ),
              StatsCard(
                label: 'Streak',
                value: '0',
                unit: 'days',
                icon: Icons.local_fire_department,
                accentColor: Colors.red,
              ),
              StatsCard(
                label: 'Reviews Due',
                value: '8',
                unit: 'items',
                icon: Icons.refresh,
                accentColor: ThingualColors.deepIndigo,
              ),
            ],
          ),
          const SizedBox(height: ThingualSpacing.xl),

          // Velocity Tracker
          SectionHeader(title: 'Velocity Tracker'),
          ThingualTileGrid(
            children: [
              StatsCard(
                label: 'Response Speed',
                value: '2.4',
                unit: 'sec avg',
                icon: Icons.speed,
                accentColor: ThingualColors.deepIndigo,
              ),
              StatsCard(
                label: 'Hesitation Level',
                value: '34',
                unit: '%',
                icon: Icons.pause,
                accentColor: ThingualColors.amber,
              ),
              StatsCard(
                label: 'Total Reviews',
                value: '342',
                unit: 'completed',
                icon: Icons.check_circle,
                accentColor: ThingualColors.vivdCyan,
              ),
            ],
          ),
          const SizedBox(height: ThingualSpacing.xl),

          // Unit Progress
          SectionHeader(title: 'Unit Progress'),
          for (int i = 1; i <= 3; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: ThingualSpacing.lg),
              child: ThingualCard(
                padding: const EdgeInsets.all(ThingualSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unit $i: ${['Greetings', 'Daily Life', 'Travel'][i - 1]}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: ThingualSpacing.md),
                    ThingualProgressBar(
                      progress: (0.4 + i * 0.15),
                      color: ThingualColors.vivdCyan,
                    ),
                    const SizedBox(height: ThingualSpacing.sm),
                    Text(
                      '${((0.4 + i * 0.15) * 100).toInt()}% complete',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: ThingualSpacing.xl),

          // Skill Breakdown
          SectionHeader(title: 'Skill Breakdown'),
          if (isMobile)
            Column(
              children: [
                _SkillCard(title: 'Grammar', accuracy: 82, icon: Icons.rule),
                const SizedBox(height: ThingualSpacing.lg),
                _SkillCard(title: 'Vocabulary', accuracy: 91, icon: Icons.book),
                const SizedBox(height: ThingualSpacing.lg),
                _SkillCard(title: 'Speaking', accuracy: 75, icon: Icons.mic),
                const SizedBox(height: ThingualSpacing.lg),
                _SkillCard(
                  title: 'Listening',
                  accuracy: 84,
                  icon: Icons.headphones,
                ),
              ],
            )
          else
            GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: ThingualSpacing.lg,
              mainAxisSpacing: ThingualSpacing.lg,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _SkillCard(title: 'Grammar', accuracy: 82, icon: Icons.rule),
                _SkillCard(title: 'Vocabulary', accuracy: 91, icon: Icons.book),
                _SkillCard(title: 'Speaking', accuracy: 75, icon: Icons.mic),
                _SkillCard(
                  title: 'Listening',
                  accuracy: 84,
                  icon: Icons.headphones,
                ),
              ],
            ),
          const SizedBox(height: ThingualSpacing.xl),

          // Activity Heatmap
          SectionHeader(title: '30-Day Activity'),
          ThingualCard(
            padding: const EdgeInsets.all(ThingualSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last 30 days',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: ThingualSpacing.lg),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: List.generate(30, (index) {
                    final isActive = (index + 1) % 3 != 0;
                    return Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isActive
                            ? ThingualColors.deepIndigo
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: ThingualSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      '18 days active',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '2.4 avg sessions/day',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: ThingualSpacing.xl),

          // Achievements
          SectionHeader(title: 'Achievements'),
          Wrap(
            spacing: ThingualSpacing.lg,
            runSpacing: ThingualSpacing.lg,
            children: [
              ThingualBadge(
                label: 'First Lesson',
                backgroundColor: Colors.yellow[100],
                textColor: Colors.amber[700],
                icon: Icons.school,
              ),
              ThingualBadge(
                label: 'Week Warrior',
                backgroundColor: Colors.blue[100],
                textColor: Colors.blue[700],
                icon: Icons.local_fire_department,
              ),
              ThingualBadge(
                label: 'Perfect Score',
                backgroundColor: Colors.green[100],
                textColor: Colors.green[700],
                icon: Icons.star,
              ),
            ],
          ),
          const SizedBox(height: ThingualSpacing.xxxl),
        ],
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  final String title;
  final int accuracy;
  final IconData icon;

  const _SkillCard({
    required this.title,
    required this.accuracy,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ThingualCard(
      padding: const EdgeInsets.all(ThingualSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(ThingualSpacing.md),
            decoration: BoxDecoration(
              color: ThingualColors.deepIndigo.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ThingualRadius.md),
            ),
            child: Icon(icon, color: ThingualColors.deepIndigo, size: 20),
          ),
          const SizedBox(height: ThingualSpacing.md),
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: ThingualSpacing.md),
          Text(
            '$accuracy%',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: ThingualColors.deepIndigo,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: ThingualSpacing.md),
          ThingualProgressBar(
            progress: accuracy / 100,
            color: ThingualColors.deepIndigo,
            height: 4,
          ),
        ],
      ),
    );
  }
}
