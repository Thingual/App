import 'package:flutter/material.dart';
import 'grammar_question_model.dart';
import 'grammar_test_service.dart';
import '../assessment_controller/assessment_controller.dart';
import '../assessment_controller/assessment_result_model.dart';

class GrammarTestScreen extends StatefulWidget {
  final AssessmentController assessmentController;
  final VoidCallback onCompleted;

  const GrammarTestScreen({
    super.key,
    required this.assessmentController,
    required this.onCompleted,
  });

  @override
  State<GrammarTestScreen> createState() => _GrammarTestScreenState();
}

class _GrammarTestScreenState extends State<GrammarTestScreen> {
  late GrammarTestService _service;
  late List<GrammarQuestion> _questions;
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  late Stopwatch _stopwatch;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service = GrammarTestService();
    _stopwatch = Stopwatch();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await _service.getRandomQuestionsForAssessment();
      setState(() {
        _questions = questions;
        _isLoading = false;
        _stopwatch.start();
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load questions: $e';
        _isLoading = false;
      });
    }
  }

  void _handleNext() {
    if (_selectedAnswer == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an answer')));
      return;
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final responseTime = _stopwatch.elapsedMilliseconds / 1000.0;
    final isCorrect = currentQuestion.isAnswerCorrect(_selectedAnswer!);

    // Record result
    widget.assessmentController.addGrammarResult(
      AssessmentQuestionResult(
        questionId: currentQuestion.id,
        sectionType: 'grammar',
        difficulty: currentQuestion.difficulty,
        selectedAnswer: _selectedAnswer!,
        correctAnswer: currentQuestion.correctAnswer,
        isCorrect: isCorrect,
        responseTime: responseTime,
      ),
    );

    // Move to next question or complete
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _stopwatch.reset();
        _stopwatch.start();
      });
    } else {
      _stopwatch.stop();
      widget.onCompleted();
    }
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(body: Center(child: Text(_error!)));
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and progress
              Text(
                'Grammar Assessment',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _questions.length,
                  minHeight: 4,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Question
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question text
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currentQuestion.question,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Options
                      ...currentQuestion.options.map(
                        (option) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _OptionTile(
                            option: option,
                            isSelected: _selectedAnswer == option,
                            onTap: () {
                              setState(() => _selectedAnswer = option);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Next button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleNext,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentQuestionIndex == _questions.length - 1
                        ? 'Complete'
                        : 'Next',
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

class _OptionTile extends StatelessWidget {
  final String option;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? colorScheme.primary : colorScheme.outline,
                  width: isSelected ? 2 : 1,
                ),
                color: isSelected ? colorScheme.primary : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 16, color: colorScheme.onPrimary)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : null,
                  color: isSelected ? colorScheme.primary : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
