import 'package:flutter/material.dart';
import 'dart:async';
import '../grammar_test/grammar_test_screen.dart';
import '../sentence_completion_test/sentence_test_screen.dart';
import '../listening_test/listening_test_screen.dart';
import '../picture_description_test/picture_description_test_screen.dart';
import '../picture_description_test/services/model_manager.dart';
import '../assessment_controller/assessment_controller.dart';
import '../../authentication/screens/success_screen.dart';
import '../assessment_controller/assessment_result_model.dart';

enum LearningPace { casual, serious, intensive }

enum OnboardingStep {
  pace,
  interests,
  modelDownload,
  grammarTest,
  sentenceTest,
  listeningTest,
  pictureDescriptionTest,
  results,
}

class PostLoginOnboardingScreen extends StatefulWidget {
  const PostLoginOnboardingScreen({super.key});

  @override
  State<PostLoginOnboardingScreen> createState() =>
      _PostLoginOnboardingScreenState();
}

class _PostLoginOnboardingScreenState extends State<PostLoginOnboardingScreen> {
  late OnboardingStep _currentStep;
  LearningPace? _pace;
  late AssessmentController _assessmentController;
  late ModelManager _modelManager;

  AssessmentResult? _finalResult;

  final Set<String> _selectedInterests = <String>{
    // default empty
  };

  static const List<_InterestOption> _interestOptions = [
    _InterestOption('Technology'),
    _InterestOption('Travel'),
    _InterestOption('Business'),
    _InterestOption('Gaming'),
    _InterestOption('Movies'),
    _InterestOption('Food'),
    _InterestOption('Sports'),
    _InterestOption('Education'),
    _InterestOption('Culture'),
  ];

  @override
  void initState() {
    super.initState();
    _currentStep = OnboardingStep.pace;
    _assessmentController = AssessmentController();
    _modelManager = ModelManager();
    _modelManager.initialize();
  }

  void _goNext() {
    if (_currentStep == OnboardingStep.pace) {
      setState(() => _currentStep = OnboardingStep.interests);
      return;
    }

    if (_currentStep == OnboardingStep.interests) {
      setState(() => _currentStep = OnboardingStep.modelDownload);
      return;
    }

    if (_currentStep == OnboardingStep.modelDownload) {
      setState(() => _currentStep = OnboardingStep.grammarTest);
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Assessment completed.')));
  }

  void _handleGrammarTestCompleted() {
    setState(() => _currentStep = OnboardingStep.sentenceTest);
  }

  void _handleSentenceTestCompleted() {
    setState(() => _currentStep = OnboardingStep.listeningTest);
  }

  void _handleListeningTestCompleted() {
    setState(() => _currentStep = OnboardingStep.pictureDescriptionTest);
  }

  void _handlePictureDescriptionCompleted() {
    final result = _assessmentController.getFinalResult();
    if (result != null) {
      setState(() {
        _finalResult = result;
        _currentStep = OnboardingStep.results;
      });
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not compute assessment result.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Show model download screen
    if (_currentStep == OnboardingStep.modelDownload) {
      return _ModelDownloadScreen(
        modelManager: _modelManager,
        onCompleted: _goNext,
      );
    }

    // Show grammar test screen
    if (_currentStep == OnboardingStep.grammarTest) {
      return GrammarTestScreen(
        assessmentController: _assessmentController,
        onCompleted: _handleGrammarTestCompleted,
      );
    }

    // Show sentence completion test screen
    if (_currentStep == OnboardingStep.sentenceTest) {
      return SentenceCompletionTestScreen(
        assessmentController: _assessmentController,
        onCompleted: _handleSentenceTestCompleted,
      );
    }

    if (_currentStep == OnboardingStep.listeningTest) {
      return ListeningTestScreen(
        assessmentController: _assessmentController,
        onCompleted: _handleListeningTestCompleted,
      );
    }

    if (_currentStep == OnboardingStep.pictureDescriptionTest) {
      return PictureDescriptionTestScreen(
        assessmentController: _assessmentController,
        onCompleted: _handlePictureDescriptionCompleted,
        modelManager: _modelManager,
      );
    }

    if (_currentStep == OnboardingStep.results) {
      final result = _finalResult;
      if (result == null) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: Text(
                'No results available.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        );
      }

      return _AssessmentResultsScreen(
        result: result,
        onFinish: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const SuccessScreen()),
            (route) => false,
          );
        },
      );
    }

    // Show onboarding steps (pace, interests)
    final stepNumber = _currentStep == OnboardingStep.pace ? 1 : 2;
    final totalSteps = 2;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Step $stepNumber of $totalSteps',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colorScheme.primary),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _currentStep == OnboardingStep.pace
                      ? _PaceStep(
                          key: const ValueKey('pace'),
                          pace: _pace,
                          onChanged: (pace) => setState(() => _pace = pace),
                        )
                      : _InterestsStep(
                          key: const ValueKey('interests'),
                          selected: _selectedInterests,
                          options: _interestOptions,
                          onToggle: (label) {
                            setState(() {
                              if (_selectedInterests.contains(label)) {
                                _selectedInterests.remove(label);
                              } else if (_selectedInterests.length < 3) {
                                _selectedInterests.add(label);
                              }
                            });
                          },
                        ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      _currentStep == OnboardingStep.pace && _pace == null
                      ? null
                      : _goNext,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentStep == OnboardingStep.pace
                        ? 'Continue'
                        : 'Start Assessment',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaceStep extends StatelessWidget {
  const _PaceStep({super.key, required this.pace, required this.onChanged});

  final LearningPace? pace;
  final ValueChanged<LearningPace> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How fast do you want\nto learn?',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        _PaceTile(
          title: 'Casual',
          badge: '10min/day',
          subtitle: 'Learn at a relaxed, comfortable\npace',
          icon: Icons.access_time,
          value: LearningPace.casual,
          groupValue: pace,
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
        _PaceTile(
          title: 'Serious',
          badge: '20min/day',
          subtitle: 'Build Consistency, Lasting\nfluency',
          icon: Icons.menu_book,
          value: LearningPace.serious,
          groupValue: pace,
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
        _PaceTile(
          title: 'Intensive',
          badge: '30min/day',
          subtitle: 'Accelerate towards rapid\nmastery',
          icon: Icons.fitness_center,
          value: LearningPace.intensive,
          groupValue: pace,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _PaceTile extends StatelessWidget {
  const _PaceTile({
    required this.title,
    required this.badge,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final String badge;
  final String subtitle;
  final IconData icon;
  final LearningPace value;
  final LearningPace? groupValue;
  final ValueChanged<LearningPace> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = value == groupValue;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: colorScheme.onPrimary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badge,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected ? colorScheme.primary : colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InterestsStep extends StatelessWidget {
  const _InterestsStep({
    super.key,
    required this.selected,
    required this.options,
    required this.onToggle,
  });

  final Set<String> selected;
  final List<_InterestOption> options;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isAtMaxSelection = selected.length >= 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tailor your curriculum.',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Select your interests',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final option in options)
              Builder(
                builder: (context) {
                  final isSelected = selected.contains(option.label);
                  return FilterChip(
                    label: Text(option.label),
                    selected: isSelected,
                    onSelected: isSelected
                        ? (_) => onToggle(option.label)
                        : isAtMaxSelection
                        ? null
                        : (_) => onToggle(option.label),
                    showCheckmark: false,
                    selectedColor: colorScheme.primary,
                    labelStyle: Theme.of(context).textTheme.labelLarge
                        ?.copyWith(
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _InterestOption {
  const _InterestOption(this.label);

  final String label;
}

class _AssessmentResultsScreen extends StatelessWidget {
  const _AssessmentResultsScreen({
    required this.result,
    required this.onFinish,
  });

  final AssessmentResult result;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Assessment Results',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Here\'s how you did across sections.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Overall score',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${result.overallScore.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ScoreTile(
                title: 'Grammar',
                scoreText: '${result.grammarScore.toStringAsFixed(1)}%',
                subtitle: '${result.grammarResults.length} questions',
              ),
              const SizedBox(height: 12),
              _ScoreTile(
                title: 'Sentence completion',
                scoreText:
                    '${result.sentenceCompletionScore.toStringAsFixed(1)}%',
                subtitle:
                    '${result.sentenceCompletionResults.length} questions',
              ),
              const SizedBox(height: 12),
              _ScoreTile(
                title: 'Listening',
                scoreText: '${result.listeningScore.toStringAsFixed(1)}%',
                subtitle: '${result.listeningResults.length} prompts',
              ),
              const SizedBox(height: 12),
              _PictureDescriptionScoreTile(
                score: result.pictureDescriptionScore,
                count: result.pictureDescriptionResults.length,
                results: result.pictureDescriptionResults,
              ),
              const Spacer(),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: onFinish,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Finish'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreTile extends StatelessWidget {
  const _ScoreTile({
    required this.title,
    required this.scoreText,
    required this.subtitle,
  });

  final String title;
  final String scoreText;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            scoreText,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PictureDescriptionScoreTile extends StatelessWidget {
  const _PictureDescriptionScoreTile({
    required this.score,
    required this.count,
    required this.results,
  });

  final double score;
  final int count;
  final List<AssessmentQuestionResult> results;

  String _getScoringSourceLabel() {
    if (results.isEmpty) return 'No data';

    final firstResult = results.first;
    final source = firstResult.scoringSource ?? 'unknown';

    if (source == 'llm') {
      return 'AI Scoring';
    } else if (source == 'rule_engine') {
      return 'Rule-Based';
    } else {
      return 'Standard';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sourceLabel = _getScoringSourceLabel();
    final isLlmScored =
        results.isNotEmpty && results.first.scoringSource == 'llm';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
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
                      'Picture Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count description(s)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${score.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isLlmScored
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLlmScored ? Icons.smart_toy : Icons.rule,
                  size: 16,
                  color: isLlmScored
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  'Scored by: $sourceLabel',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isLlmScored
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
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

class _ModelDownloadScreen extends StatefulWidget {
  final ModelManager modelManager;
  final VoidCallback onCompleted;

  const _ModelDownloadScreen({
    required this.modelManager,
    required this.onCompleted,
  });

  @override
  State<_ModelDownloadScreen> createState() => _ModelDownloadScreenState();
}

class _ModelDownloadScreenState extends State<_ModelDownloadScreen> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  Future<void> _startDownload() async {
    if (_isDownloading) return;

    setState(() => _isDownloading = true);
    
    // Listen to real download progress from ModelManager
    widget.modelManager.addListener(_updateDownloadProgress);
    
    try {
      debugPrint('[_ModelDownloadScreen] Starting real model download...');
      debugPrint('[_ModelDownloadScreen] Model URL: ${ModelManager.modelDownloadUrl}');
      debugPrint('[_ModelDownloadScreen] Listening to real download progress...');
      
      await widget.modelManager.downloadModel();
      
      if (mounted) {
        setState(() => _isDownloading = false);
        widget.onCompleted();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
      }
    } finally {
      // Remove listener when done
      widget.modelManager.removeListener(_updateDownloadProgress);
    }
  }

  void _updateDownloadProgress() {
    if (mounted) {
      setState(() {
        _downloadProgress = widget.modelManager.downloadProgress;
        
        // Log progress at key milestones
        final percentage = (_downloadProgress * 100).toInt();
        if (percentage % 10 == 0 || percentage == 100) {
          debugPrint(
            '[_ModelDownloadScreen] Download progress: $percentage%',
          );
        }
      });
    }
  }
  
  @override
  void dispose() {
    widget.modelManager.removeListener(_updateDownloadProgress);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isModelAvailable = widget.modelManager.isModelAvailable;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'AI-Powered Evaluation',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'Unlock advanced language assessment with our AI evaluation pack. Get detailed feedback beyond rule-based scoring.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Benefits Card
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BenefitItem(
                        icon: Icons.psychology,
                        title: 'Intelligent Scoring',
                        description:
                            'AI-powered assessment combines rules with language models',
                      ),
                      const SizedBox(height: 16),
                      _BenefitItem(
                        icon: Icons.cloud_done,
                        title: 'Fully Offline',
                        description:
                            'Once downloaded, works completely offline - no data sharing',
                      ),
                      const SizedBox(height: 16),
                      _BenefitItem(
                        icon: Icons.speed,
                        title: 'Fast & Responsive',
                        description:
                            'Instant feedback on your language descriptions',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Status Section
                if (isModelAvailable)
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: colorScheme.secondary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Pack Ready',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: colorScheme.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'Model is available and ready to use',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: colorScheme.onSecondaryContainer,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else if (_isDownloading)
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _downloadProgress,
                          minHeight: 8,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Downloading... ${(_downloadProgress * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 32),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isModelAvailable || _isDownloading
                        ? null
                        : _startDownload,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        isModelAvailable
                            ? 'AI Pack Downloaded'
                            : _isDownloading
                            ? 'Downloading...'
                            : 'Download AI Evaluation Pack',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Skip Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: widget.onCompleted,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Skip for Now',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.primary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
