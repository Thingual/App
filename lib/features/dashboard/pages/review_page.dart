import 'package:flutter/material.dart';
import '../../../core/constants/brand_colors.dart';
import '../../../core/constants/theme.dart';
import '../../../shared/widgets/thingual_widgets.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.all(
          isMobile ? ThingualSpacing.lg : ThingualSpacing.xl,
        ),
        children: [
          // Hero Banner
          Container(
            padding: const EdgeInsets.all(ThingualSpacing.xl),
            decoration: BoxDecoration(
              gradient: ThingualColors.primaryGradient,
              borderRadius: BorderRadius.circular(ThingualRadius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready to Review?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: ThingualSpacing.sm),
                Text(
                  'Strengthen your knowledge with targeted practice',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ThingualSpacing.xl),

          // Tabs
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _ReviewTab(
                  label: 'Due Now',
                  isSelected: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                ),
                _ReviewTab(
                  label: 'Weak Areas',
                  isSelected: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: ThingualSpacing.xl),

          // Content based on tab
          if (_selectedTab == 0) ...[
            // Due Now Tab
            SectionHeader(title: 'Reviews Due'),
            ThingualCard(
              padding: const EdgeInsets.all(ThingualSpacing.lg),
              onTap: () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vocabulary Review',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: ThingualSpacing.sm),
                  Text(
                    '5 words need review',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: ThingualSpacing.lg),
                  ThingualProgressBar(
                    progress: 0.4,
                    color: ThingualColors.vivdCyan,
                  ),
                  const SizedBox(height: ThingualSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Review'),
                      ),
                      Text(
                        '~8 min',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: ThingualSpacing.lg),
            ThingualCard(
              padding: const EdgeInsets.all(ThingualSpacing.lg),
              onTap: () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grammar Review',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: ThingualSpacing.sm),
                  Text(
                    '3 topics to practice',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: ThingualSpacing.lg),
                  ThingualProgressBar(
                    progress: 0.6,
                    color: ThingualColors.amber,
                  ),
                  const SizedBox(height: ThingualSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Review'),
                      ),
                      Text(
                        '~12 min',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            // Weak Areas Tab
            SectionHeader(title: 'Areas to Improve'),
            ThingualCard(
              padding: const EdgeInsets.all(ThingualSpacing.lg),
              onTap: () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Past Tense Conjugation',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: ThingualSpacing.sm),
                  Text(
                    'Accuracy: 65% • 12 attempts',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: ThingualSpacing.lg),
                  ThingualProgressBar(progress: 0.65, color: Colors.orange),
                  const SizedBox(height: ThingualSpacing.lg),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Practice Now'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ThingualSpacing.lg),
            ThingualCard(
              padding: const EdgeInsets.all(ThingualSpacing.lg),
              onTap: () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phrasal Verbs',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: ThingualSpacing.sm),
                  Text(
                    'Accuracy: 58% • 8 attempts',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: ThingualSpacing.lg),
                  ThingualProgressBar(progress: 0.58, color: Colors.orange),
                  const SizedBox(height: ThingualSpacing.lg),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Practice Now'),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: ThingualSpacing.xl),

          // Review Intensity Card
          SectionHeader(title: 'Review Intensity'),
          ThingualCard(
            padding: const EdgeInsets.all(ThingualSpacing.lg),
            child: ThingualTileGrid(
              childAspectRatio: isMobile ? 1.15 : 1.55,
              children: [
                StatsCard(
                  label: 'Total Reviews',
                  value: '342',
                  unit: 'reviews',
                  icon: Icons.check_circle,
                  accentColor: ThingualColors.vivdCyan,
                ),
                StatsCard(
                  label: 'Active Days',
                  value: '24',
                  unit: 'days',
                  icon: Icons.calendar_today,
                  accentColor: ThingualColors.deepIndigo,
                ),
                StatsCard(
                  label: 'Best Day',
                  value: '42',
                  unit: 'reviews',
                  icon: Icons.trending_up,
                  accentColor: ThingualColors.amber,
                ),
              ],
            ),
          ),
          const SizedBox(height: ThingualSpacing.xxxl),
        ],
      ),
    );
  }
}

class _ReviewTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReviewTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: ThingualSpacing.lg),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ThingualSpacing.lg,
            vertical: ThingualSpacing.md,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? ThingualColors.deepIndigo
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isSelected ? ThingualColors.deepIndigo : Colors.grey[500],
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
