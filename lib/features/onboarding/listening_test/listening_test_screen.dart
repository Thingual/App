import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../assessment_controller/assessment_controller.dart';
import '../assessment_controller/assessment_result_model.dart';
import 'listening_question_model.dart';
import 'listening_scoring.dart';
import 'listening_test_service.dart';

enum _ListeningInputMode { speak, type }

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
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  final TextEditingController _answerController = TextEditingController();
  _ListeningInputMode _mode = _ListeningInputMode.type;

  late Stopwatch _stopwatch;

  bool _isLoading = true;
  String? _error;
  bool _isSpeaking = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _service = ListeningTestService();
    _stopwatch = Stopwatch();
    _initTts();
    _initSpeechToText();
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

  Future<void> _initSpeechToText() async {
    try {
      await _speechToText.initialize(
        onError: (error) {
          print('🎤 Speech-to-text error: $error');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Speech error: $error')),
            );
          }
        },
        onStatus: (status) => print('🎤 Speech status: $status'),
      );
    } catch (e) {
      print('❌ Speech-to-text init failed: $e');
    }
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

  Future<void> _startListening() async {
    if (_isListening) return;

    final permission = await Permission.microphone.request();
    if (!permission.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission required')),
        );
      }
      return;
    }

    if (!_speechToText.isAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech-to-text not available')),
        );
      }
      return;
    }

    setState(() => _isListening = true);

    try {
      await _speechToText.listen(
        onResult: (result) {
          print('🎤 Heard: ${result.recognizedWords}');
          setState(() {
            _answerController.text = result.recognizedWords;
          });
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        onSoundLevelChange: (level) => print('🔊 Sound level: $level'),
      );
    } catch (e) {
      print('❌ Listen error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _stopListening() async {
    if (!_isListening) return;
    await _speechToText.stop();
    setState(() => _isListening = false);
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
    _speechToText.cancel();
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
                              'Listen and write what you hear',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Play the audio, then type your response or use speech recognition.',
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
                            const SizedBox(height: 16),
                            if (_mode == _ListeningInputMode.speak)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _isListening
                                      ? _stopListening
                                      : _startListening,
                                  icon: Icon(
                                    _isListening
                                        ? Icons.stop_circle
                                        : Icons.mic,
                                  ),
                                  label: Text(
                                    _isListening
                                        ? 'Stop Recording'
                                        : 'Tap to Speak',
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            SegmentedButton<_ListeningInputMode>(
                              segments: const <ButtonSegment<_ListeningInputMode>>[
                                ButtonSegment<_ListeningInputMode>(
                                  value: _ListeningInputMode.type,
                                  label: Text('Type'),
                                  icon: Icon(Icons.keyboard),
                                ),
                                ButtonSegment<_ListeningInputMode>(
                                  value: _ListeningInputMode.speak,
                                  label: Text('Speak'),
                                  icon: Icon(Icons.mic),
                                ),
                              ],
                              selected: <_ListeningInputMode>{_mode},
                              onSelectionChanged:
                                  (Set<_ListeningInputMode> newSelection) {
                                setState(() {
                                  _mode = newSelection.first;
                                });
                              },
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
                          hintText: 'Type or speak your answer here...',
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
