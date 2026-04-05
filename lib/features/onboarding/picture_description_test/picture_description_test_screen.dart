import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './models/picture_model.dart';
import './services/picture_dataset_service.dart';
import './services/rule_engine.dart';
import './services/llm_service.dart';
import './services/scoring_service.dart';
import './services/model_manager.dart';
import './../assessment_controller/assessment_controller.dart';
import './../assessment_controller/assessment_result_model.dart';

/// Screen for Picture Description Assessment
class PictureDescriptionTestScreen extends StatefulWidget {
  final AssessmentController assessmentController;
  final VoidCallback onCompleted;
  final ModelManager modelManager;

  const PictureDescriptionTestScreen({
    super.key,
    required this.assessmentController,
    required this.onCompleted,
    required this.modelManager,
  });

  @override
  State<PictureDescriptionTestScreen> createState() =>
      _PictureDescriptionTestScreenState();
}

class _PictureDescriptionTestScreenState
    extends State<PictureDescriptionTestScreen> {
  Picture? _picture;
  bool _isLoading = true;
  String? _error;

  late TextEditingController _descriptionController;
  late Stopwatch _responseTimer;

  bool _isSubmitting = false;
  String _submitButtonText = 'Submit';

  final _datasetService = PictureDatasetService();
  late final _llmService = LLMServiceStub();
  late final _scoringService = ScoringService(
    ruleEngine: RuleEngine(),
    llmService: _llmService,
  );

  @override
  void initState() {
    super.initState();
    print('[PictureDescription] initState started');
    _descriptionController = TextEditingController();
    _responseTimer = Stopwatch();
    _initializeLlmService();
    _loadPicture();
  }

  Future<void> _initializeLlmService() async {
    try {
      print('[PictureDescription] Checking if LLM model is available...');
      print(
        '[PictureDescription] Model available: ${widget.modelManager.isModelAvailable}',
      );
      print(
        '[PictureDescription] Model path: ${widget.modelManager.modelPath}',
      );

      if (widget.modelManager.isModelAvailable &&
          widget.modelManager.modelPath != null) {
        print(
          '[PictureDescription] Initializing LLM service with model: ${widget.modelManager.modelPath}',
        );
        await _llmService.initialize(widget.modelManager.modelPath!);
        print('[PictureDescription] LLM service initialized successfully');
      } else {
        print(
          '[PictureDescription] LLM model not available, will use rule-based scoring only',
        );
      }
    } catch (e) {
      print('[PictureDescription] Error initializing LLM service: $e');
    }
  }

  Future<void> _loadPicture() async {
    try {
      setState(() => _isLoading = true);
      print('[PictureDescription] Starting to load picture...');

      final picture = await _datasetService.getFirstPicture();
      if (picture == null) {
        print('[PictureDescription] ERROR: No pictures available');
        setState(() {
          _error = 'No pictures available';
          _isLoading = false;
        });
        return;
      }

      print(
        '[PictureDescription] Picture loaded: ID=${picture.id}, imagePath="${picture.imagePath}"',
      );

      setState(() {
        _picture = picture;
        _isLoading = false;
        _responseTimer.start();
      });
    } catch (e) {
      print('[PictureDescription] ERROR loading picture: $e');
      setState(() {
        _error = 'Failed to load picture: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _submitDescription() async {
    final description = _descriptionController.text.trim();

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a description')),
      );
      return;
    }

    _responseTimer.stop();

    setState(() {
      _isSubmitting = true;
      _submitButtonText = 'Evaluating...';
    });

    try {
      final picture = _picture;
      if (picture == null) return;

      print('[PictureDescription] Submitting description for scoring');
      print(
        '[PictureDescription] Model available: ${widget.modelManager.isModelAvailable}',
      );
      print(
        '[PictureDescription] LLM service initialized: ${_llmService.isInitialized}',
      );

      // Get reference description (B1 level for scoring)
      final referenceDesc = picture.getReferenceByCefr('B1') ?? '';

      // Score the description
      print(
        '[PictureDescription] Calling scoreDescription with useIllm=${widget.modelManager.isModelAvailable}',
      );
      final score = await _scoringService.scoreDescription(
        userResponse: description,
        keywords: picture.keywords,
        responseTimeMs: _responseTimer.elapsedMilliseconds,
        imageContext: referenceDesc,
        useIllm: widget.modelManager.isModelAvailable,
      );

      // Add result to assessment controller
      final result = AssessmentQuestionResult(
        questionId: picture.id,
        sectionType: 'picture_description',
        difficulty: 'medium',
        selectedAnswer: description,
        correctAnswer: referenceDesc,
        isCorrect: score.finalScore >= 60,
        responseTime: score.responseTimeMs / 1000.0,
        numericScore: score.finalScore / 100.0,
        scoringSource: score.isLlmScored ? 'llm' : 'rule_engine',
      );

      widget.assessmentController.addPictureDescriptionResult(result);

      // Navigate to results
      if (mounted) {
        widget.onCompleted();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _submitButtonText = 'Submit';
        });
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _responseTimer.stop();
    super.dispose();
  }

  Widget _buildImagePlaceholder(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'Could not load image',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAssetImage(String imagePath, ColorScheme colorScheme) {
    // Try multiple path variations to load the asset
    final paths = [
      imagePath, // Original path
      'assets/$imagePath', // With assets/ prefix
    ];

    return Image(
      image: AssetImage(imagePath),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('[PictureDescription] Image load error for "$imagePath": $error');
        print('[PictureDescription] Tried paths: $paths');

        // Try with assets/ prefix
        return Image(
          image: AssetImage('assets/$imagePath'),
          fit: BoxFit.cover,
          errorBuilder: (context, error2, stackTrace2) {
            print(
              '[PictureDescription] Also failed with assets/ prefix: $error2',
            );
            return _buildImagePlaceholder(colorScheme);
          },
        );
      },
    );
  }

  Future<void> _debugAssetBundle() async {
    try {
      print('[DEBUG] Checking asset bundle contents...');
      final manifestJson = await rootBundle.loadString('AssetManifest.json');
      print('[DEBUG] AssetManifest.json loaded');
      print('[DEBUG] Contents: $manifestJson');
    } catch (e) {
      print('[DEBUG] Error loading AssetManifest: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: const Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(body: Center(child: Text('Error: $_error')));
    }

    final picture = _picture;
    if (picture == null) {
      return Scaffold(body: const Center(child: Text('No picture available')));
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Picture Description'), elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step indicator
              Text(
                'Step 4 of 4',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colorScheme.primary),
              ),
              const SizedBox(height: 16),

              // Instructions
              Text(
                'Describe the image',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Write a detailed description of what you see in the image. Take your time and be as descriptive as you can.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Image display
              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline),
                  color: colorScheme.surfaceContainerHighest,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: picture.imagePath.startsWith('http')
                      ? Image.network(
                          picture.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder(colorScheme);
                          },
                        )
                      : _buildAssetImage(picture.imagePath, colorScheme),
                ),
              ),
              const SizedBox(height: 24),

              // LLM status banner
              if (!widget.modelManager.isModelAvailable)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Scoring Not Enabled',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Download the AI Pack for enhanced evaluation.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (!widget.modelManager.isModelAvailable)
                const SizedBox(height: 16),

              // Download button
              if (!widget.modelManager.isModelAvailable)
                SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: widget.modelManager.isDownloading
                        ? null
                        : () => _showDownloadDialog(),
                    icon: const Icon(Icons.download),
                    label: Text(
                      widget.modelManager.isDownloading
                          ? 'Downloading...'
                          : 'Download AI Pack',
                    ),
                  ),
                ),
              if (!widget.modelManager.isModelAvailable)
                const SizedBox(height: 24),

              // Description input
              TextField(
                controller: _descriptionController,
                maxLines: 8,
                minLines: 8,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitDescription,
                  child: _isSubmitting
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Text(_submitButtonText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDownloadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download AI Evaluation Pack'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Download the TinyLlama model (~500MB) for AI-powered evaluation.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (widget.modelManager.isDownloading)
              Column(
                children: [
                  LinearProgressIndicator(
                    value: widget.modelManager.downloadProgress,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(widget.modelManager.downloadProgress * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          if (!widget.modelManager.isDownloading)
            ElevatedButton(
              onPressed: () {
                widget.modelManager.downloadModel();
                Navigator.pop(context);
              },
              child: const Text('Download'),
            ),
        ],
      ),
    );
  }
}
