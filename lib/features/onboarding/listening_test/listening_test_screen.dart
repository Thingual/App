import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../../core/services/api_service.dart';
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
  final AudioRecorder _recorder = AudioRecorder();
  final ApiService _apiService = ApiService();

  final TextEditingController _answerController = TextEditingController();
  _ListeningInputMode _mode = _ListeningInputMode.speak;

  late Stopwatch _stopwatch;

  bool _isLoading = true;
  String? _error;

  bool _isSpeaking = false;
  bool _isRecording = false;
  bool _isTranscribing = false;
  String? _recordingPath;

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
      if (!mounted) return;
      setState(() => _isSpeaking = true);
    });

    _tts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    });

    _tts.setErrorHandler((_) {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
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

  Future<bool> _ensureMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<String> _newTempRecordingPath() async {
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${dir.path}${Platform.pathSeparator}listening_$timestamp.m4a';
  }

  Future<void> _toggleRecording() async {
    if (_isTranscribing) return;

    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() {
        _isRecording = false;
        _recordingPath = path;
      });

      if (path == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recording failed to save.')),
        );
        return;
      }

      await _transcribe(path);
      return;
    }

    final hasPermission = await _ensureMicPermission();
    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required.')),
      );
      return;
    }

    final path = await _newTempRecordingPath();

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        numChannels: 1,
        sampleRate: 16000,
      ),
      path: path,
    );

    setState(() {
      _isRecording = true;
      _recordingPath = path;
    });
  }

  Future<void> _transcribe(String filePath) async {
    setState(() => _isTranscribing = true);

    try {
      print('🎤 Starting transcription for file: $filePath');
      final text = await _apiService.transcribeListeningAudio(
        filePath: filePath,
        filename: 'listening.m4a',
      );

      print('✅ Transcription successful: $text');
      if (!mounted) return;
      setState(() {
        _answerController.text = text.trim();
        _isTranscribing = false;
      });
    } catch (e) {
      print('❌ Transcription failed: $e');
      if (!mounted) return;
      setState(() => _isTranscribing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transcription failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleNext() {
    final answer = _answerController.text.trim();
    if (answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide your answer.')),
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
        _recordingPath = null;
        _isRecording = false;
        _stopwatch
          ..reset()
          ..start();
      });
    } else {
      _stopwatch.stop();
      widget.onCompleted();
    }
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _tts.stop();
    _recorder.dispose();
    _answerController.dispose();
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
                              'You can type it, or repeat it out loud.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _playPrompt,
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: Icon(
                                      _isSpeaking
                                          ? Icons.stop
                                          : Icons.volume_up,
                                      color: colorScheme.primary,
                                    ),
                                    label: Text(
                                      _isSpeaking ? 'Stop' : 'Play audio',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _ModeToggle(
                                  mode: _mode,
                                  onChanged: (m) => setState(() => _mode = m),
                                ),
                              ],
                            ),
                            if (_mode == _ListeningInputMode.speak) ...[
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _toggleRecording,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: Icon(
                                    _isRecording
                                        ? Icons.stop
                                        : _isTranscribing
                                        ? Icons.hourglass_top
                                        : Icons.mic,
                                  ),
                                  label: Text(
                                    _isRecording
                                        ? 'Stop recording'
                                        : _isTranscribing
                                        ? 'Transcribing…'
                                        : 'Tap to record',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                              if (_recordingPath != null && !_isRecording) ...[
                                const SizedBox(height: 10),
                                Text(
                                  'Recorded: ${File(_recordingPath!).uri.pathSegments.last}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Your answer',
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
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: 'Type what you heard…',
                          filled: true,
                          fillColor: colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 2,
                            ),
                          ),
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
                  onPressed: _isTranscribing ? null : _handleNext,
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

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});

  final _ListeningInputMode mode;
  final ValueChanged<_ListeningInputMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeChip(
            label: 'Speak',
            icon: Icons.mic,
            isSelected: mode == _ListeningInputMode.speak,
            onTap: () => onChanged(_ListeningInputMode.speak),
          ),
          _ModeChip(
            label: 'Type',
            icon: Icons.keyboard,
            isSelected: mode == _ListeningInputMode.type,
            onTap: () => onChanged(_ListeningInputMode.type),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
