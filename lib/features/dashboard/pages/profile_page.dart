import 'package:flutter/material.dart';
import '../../../core/constants/brand_colors.dart';
import '../../../core/constants/theme.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/google_auth_service.dart';
import '../../authentication/screens/login_screen.dart';
import '../../../shared/widgets/thingual_widgets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authService = AuthService();
  final _googleAuthService = GoogleAuthService();
  bool _isLoading = false;

  Future<void> _logout() async {
    setState(() => _isLoading = true);

    try {
      // Clear stored JWT token
      await _authService.logout();
      // Sign out from Google if signed in
      await _googleAuthService.signOut();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.all(
          isMobile ? ThingualSpacing.lg : ThingualSpacing.xl,
        ),
        children: [
          // Profile Header
          ThingualCard(
            padding: const EdgeInsets.all(ThingualSpacing.xl),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: ThingualColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.person, color: Colors.white, size: 48),
                  ),
                ),
                const SizedBox(height: ThingualSpacing.lg),
                Text(
                  'Alex Johnson',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ThingualSpacing.sm),
                Text(
                  'alex.johnson@email.com',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ThingualSpacing.lg),
                Text(
                  'Member since March 2024',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: ThingualSpacing.xl),

          // Stats Hero
          Container(
            padding: const EdgeInsets.all(ThingualSpacing.xl),
            decoration: BoxDecoration(
              gradient: ThingualColors.primaryGradient,
              borderRadius: BorderRadius.circular(ThingualRadius.lg),
            ),
            child: GridView.count(
              crossAxisCount: isMobile ? 2 : 4,
              crossAxisSpacing: ThingualSpacing.md,
              mainAxisSpacing: ThingualSpacing.md,
              // Lower ratio => taller cells => prevents vertical overflow.
              childAspectRatio: isMobile ? 1.75 : 2.2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _StatItem(
                  label: 'Streak',
                  value: '0',
                  icon: Icons.local_fire_department,
                  isDark: true,
                ),
                _StatItem(
                  label: 'Words',
                  value: '3.2K',
                  icon: Icons.book,
                  isDark: true,
                ),
                _StatItem(
                  label: 'Lessons',
                  value: '24',
                  icon: Icons.school,
                  isDark: true,
                ),
                _StatItem(
                  label: 'Accuracy',
                  value: '87%',
                  icon: Icons.favorite,
                  isDark: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: ThingualSpacing.xl),

          // Account Settings Section
          SectionHeader(title: 'Account Settings'),
          _SettingsItem(
            icon: Icons.person,
            title: 'Personal Information',
            subtitle: 'Name, email, profile picture',
            onTap: () {},
          ),
          _SettingsItem(
            icon: Icons.school,
            title: 'Learning Profile',
            subtitle: 'Adjust curriculum and goals',
            onTap: () {},
          ),
          _SettingsItem(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            onTap: () {},
          ),
          _SettingsItem(
            icon: Icons.lock,
            title: 'Security',
            subtitle: 'Password and login settings',
            onTap: () {},
          ),
          _SettingsItem(
            icon: Icons.privacy_tip,
            title: 'Privacy',
            subtitle: 'Privacy and data settings',
            onTap: () {},
          ),
          const SizedBox(height: ThingualSpacing.xl),

          // Subscription Section
          SectionHeader(title: 'Subscription'),
          ThingualCard(
            padding: const EdgeInsets.all(ThingualSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Premium Plan',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: ThingualSpacing.xs),
                        Text(
                          'Active until March 2025',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    ThingualBadge(
                      label: 'Active',
                      backgroundColor: Colors.green[100],
                      textColor: Colors.green[700],
                      icon: Icons.check_circle,
                    ),
                  ],
                ),
                const SizedBox(height: ThingualSpacing.lg),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Manage Subscription'),
                ),
              ],
            ),
          ),
          const SizedBox(height: ThingualSpacing.xl),

          // Vocabulary Library
          SectionHeader(title: 'Vocabulary Library'),
          ThingualCard(
            padding: const EdgeInsets.all(ThingualSpacing.lg),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const _VocabularyLibraryModal(),
                ),
              );
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(ThingualSpacing.md),
                  decoration: BoxDecoration(
                    color: ThingualColors.deepIndigo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(ThingualRadius.md),
                  ),
                  child: const Icon(
                    Icons.book,
                    color: ThingualColors.deepIndigo,
                  ),
                ),
                const SizedBox(width: ThingualSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vocabulary Library',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: ThingualSpacing.xs),
                      Text(
                        'Tap to review mastered words',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
          const SizedBox(height: ThingualSpacing.xl),

          // Help & Support
          SectionHeader(title: 'Help & Support'),
          _SettingsItem(
            icon: Icons.help,
            title: 'Help Center',
            subtitle: 'Get help and find answers',
            onTap: () {},
          ),
          _SettingsItem(
            icon: Icons.rate_review,
            title: 'Rate Us',
            subtitle: 'Share your feedback',
            onTap: () {},
          ),
          _SettingsItem(
            icon: Icons.info,
            title: 'About Thingual',
            subtitle: 'Version 1.0.0',
            onTap: () {},
          ),
          const SizedBox(height: ThingualSpacing.xl),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _logout,
              icon: _isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : const Icon(Icons.logout),
              label: Text(_isLoading ? 'Logging out...' : 'Log Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: ThingualSpacing.xxxl),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isDark;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: isDark ? Colors.white : null, size: 24),
        const SizedBox(height: ThingualSpacing.sm),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: isDark ? Colors.white : null,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: ThingualSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isDark
                ? Colors.white.withValues(alpha: 0.7)
                : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ThingualSpacing.lg,
            vertical: ThingualSpacing.md,
          ),
          child: Row(
            children: [
              Icon(icon, color: ThingualColors.deepIndigo, size: 24),
              const SizedBox(width: ThingualSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: ThingualSpacing.xs),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

class _VocabularyLibraryModal extends StatefulWidget {
  const _VocabularyLibraryModal();

  @override
  State<_VocabularyLibraryModal> createState() =>
      _VocabularyLibraryModalState();
}

class _VocabularyLibraryModalState extends State<_VocabularyLibraryModal> {
  final _searchController = TextEditingController();
  List<_VocabularyWord> _filteredWords = _sampleVocabulary;

  void _filterWords(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredWords = _sampleVocabulary;
      } else {
        _filteredWords = _sampleVocabulary
            .where(
              (word) =>
                  word.word.toLowerCase().contains(query.toLowerCase()) ||
                  word.meaning.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary Library'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(
            isMobile ? ThingualSpacing.lg : ThingualSpacing.xl,
          ),
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: _filterWords,
              decoration: InputDecoration(
                hintText: 'Search words...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ThingualRadius.md),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ThingualRadius.md),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ThingualRadius.md),
                  borderSide: const BorderSide(
                    color: ThingualColors.deepIndigo,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: ThingualSpacing.xl),

            // Word Count
            Text(
              '${_filteredWords.length} word${_filteredWords.length == 1 ? '' : 's'}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: ThingualSpacing.lg),

            // Vocabulary Cards
            if (isMobile)
              Column(
                children: List.generate(
                  _filteredWords.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: ThingualSpacing.lg),
                    child: _VocabularyCard(word: _filteredWords[index]),
                  ),
                ),
              )
            else
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: ThingualSpacing.lg,
                  mainAxisSpacing: ThingualSpacing.lg,
                  childAspectRatio: 1.0,
                ),
                itemCount: _filteredWords.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) =>
                    _VocabularyCard(word: _filteredWords[index]),
              ),
            const SizedBox(height: ThingualSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}

class _VocabularyCard extends StatelessWidget {
  final _VocabularyWord word;

  const _VocabularyCard({required this.word});

  @override
  Widget build(BuildContext context) {
    return ThingualCard(
      padding: const EdgeInsets.all(ThingualSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  word.word,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ThingualBadge(
                label: word.level,
                backgroundColor: _getLevelColor(
                  word.level,
                ).withValues(alpha: 0.1),
                textColor: _getLevelColor(word.level),
              ),
            ],
          ),
          const SizedBox(height: ThingualSpacing.md),
          Text(
            word.meaning,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: ThingualSpacing.md),
          Text(
            '"${word.example}"',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: ThingualSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mastery',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: ThingualSpacing.xs),
                    ThingualProgressBar(
                      progress: word.mastery / 100,
                      height: 4,
                      color: _getMasteryColor(word.mastery),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: ThingualSpacing.md),
              Text(
                'Due in ${word.dueInDays}d',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'A1':
        return ThingualColors.amber;
      case 'A2':
        return Colors.orange;
      case 'B1':
        return ThingualColors.vivdCyan;
      default:
        return ThingualColors.deepIndigo;
    }
  }

  Color _getMasteryColor(int mastery) {
    if (mastery >= 80) return Colors.green;
    if (mastery >= 60) return ThingualColors.amber;
    if (mastery >= 40) return Colors.orange;
    return Colors.red;
  }
}

class _VocabularyWord {
  final String word;
  final String meaning;
  final String example;
  final String level;
  final int mastery;
  final int dueInDays;

  _VocabularyWord({
    required this.word,
    required this.meaning,
    required this.example,
    required this.level,
    required this.mastery,
    required this.dueInDays,
  });
}

final _sampleVocabulary = [
  _VocabularyWord(
    word: 'Serendipity',
    meaning: 'Finding something good by chance',
    example: 'It was pure serendipity that I found this amazing café.',
    level: 'B1',
    mastery: 75,
    dueInDays: 2,
  ),
  _VocabularyWord(
    word: 'Ephemeral',
    meaning: 'Lasting for a very short time',
    example: 'The beauty of cherry blossoms is ephemeral, lasting only weeks.',
    level: 'B2',
    mastery: 45,
    dueInDays: 1,
  ),
  _VocabularyWord(
    word: 'Eloquent',
    meaning: 'Fluent and persuasive in speaking',
    example: 'Her eloquent speech moved the entire audience.',
    level: 'B1',
    mastery: 82,
    dueInDays: 3,
  ),
  _VocabularyWord(
    word: 'Benevolent',
    meaning: 'Kind and generous; showing goodwill',
    example: 'The benevolent donation helped many families in need.',
    level: 'B2',
    mastery: 60,
    dueInDays: 1,
  ),
  _VocabularyWord(
    word: 'Meticulous',
    meaning: 'Very careful and precise',
    example: 'She was meticulous in her work, never missing any details.',
    level: 'B1',
    mastery: 88,
    dueInDays: 4,
  ),
  _VocabularyWord(
    word: 'Ambiguous',
    meaning: 'Having more than one possible meaning',
    example: 'The instructions were ambiguous, causing confusion.',
    level: 'B1',
    mastery: 70,
    dueInDays: 2,
  ),
  _VocabularyWord(
    word: 'Pragmatic',
    meaning: 'Dealing with things in a practical, realistic way',
    example: 'He took a pragmatic approach to solve the business problem.',
    level: 'B2',
    mastery: 55,
    dueInDays: 1,
  ),
  _VocabularyWord(
    word: 'Ubiquitous',
    meaning: 'Present everywhere; constantly encountered',
    example: 'Smartphones have become ubiquitous in modern society.',
    level: 'B2',
    mastery: 40,
    dueInDays: 0,
  ),
];
