import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../assessment_controller/assessment_controller.dart';
import '../assessment_controller/assessment_result_model.dart';
import 'listening_question_model.dart';
import 'listening_scoring.dart';
import 'listening_test_service.dart';

class ListeningTestScreen extends StatefulWidget {
  final AssessmentController assessmentController;
  final VoidCallback onCompleted;

  const ListeningTestScreen({
    super.key,
    required this.assessmentController,
    required this.onCompleted,
  });

  @override
  State<ListeningTestScreen> createState() => _ListeningTestScreenState();
}

class _ListeningTestScreenState extends State<ListeningTestScreen> {
  late ListeningTestService _service;
  late List<ListeningQuestion> _questions;
  int _currentQuestionIndex = 0;

  final FlutterTts _tts = FlutterTts();
  final TextEditingController _answerController = TextEditingController();

  late Stopwatch _stopwatch;

  bool _isLoading = true;
  String? _error;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _service = ListeningTestService();
    _stopwatch = Stopwatch();
    _initTts();
    _loadQuestions();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() {
      if (mounted) setState(() => _isSpeaking = true);
    });

    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });

    _tts.setErrorHandler((_) {
      if (mounted) setState(() => _isSpeaking = false);
    });
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
        _error = 'Failed to load listening prompts: $e';
        _isLoading = false;
      });
    }
  }

  ListeningQuestion get _currentQuestion => _questions[_currentQuestionIndex];

  Future<void> _playPrompt() async {
    if (_isSpeaking) {
      await _tts.stop();
      return;
    }
    await _tts.speak(_currentQuestion.sentence);
  }

  void _handleNext() {
    final answer = _answerController.text.trim();
    if (answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide your answer')),
      );
      return;
    }

    final expected = _currentQuestion.sentence;
    final responseTime = _stopwatch.elapsedMilliseconds / 1000.0;
    final similarity = listeningSimilarityScore(
      expected: expected,
      actual: answer,
    );

    const correctThreshold = 0.85;
    final isCorrect = similarity >= correctThreshold;

    widget.assessmentController.addListeningResult(
      AssessmentQuestionResult(
        questionId: _currentQuestion.id,
        sectionType: 'listening',
        difficulty: _currentQuestion.difficulty,
        selectedAnswer: answer,
        correctAnswer: expected,
        isCorrect: isCorrect,
        responseTime: responseTime,
        numericScore: similarity,
      ),
    );

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _answerController.clear();
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
    _tts.stop();
    _answerController.dispose();
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
      return Scaffold(
        body: Center(
          child: Text(_error!),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Listening Assessment',
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
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Listen carefully',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Click the button below to hear the audio. Then type what you hear.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _playPrompt,
                                icon: Icon(
                                  _isSpeaking
                                      ? Icons.stop_circle
                                      : Icons.play_circle_outline,
                                ),
                                label: Text(
                                  _isSpeaking ? 'Stop' : 'Play Audio',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Your Answer',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _answerController,
                        minLines: 3,
                        maxLines: 6,
                        decoration: InputDecoration(
                          hintText: 'Type what you heard here...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleNext,
                  child: Text(
                    _currentQuestionIndex == _questions.length - 1
                        ? 'Complete'
                        : 'Next',
                    style: const TextStyle(fontSize: 16),
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
