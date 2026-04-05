import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

/// Manages downloaded LLM models and their availability
class ModelManager extends ChangeNotifier {
  static const String modelFileName = 'tinyllama.gguf';
  static const int modelSizeBytes = 500000000; // ~500MB
  static const String modelDownloadUrl =
      'https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf';

  bool _isModelAvailable = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _modelPath;
  String? _error;

  // Getters
  bool get isModelAvailable => _isModelAvailable;
  bool get isDownloading => _isDownloading;
  double get downloadProgress => _downloadProgress;
  String? get modelPath => _modelPath;
  String? get error => _error;

  /// Initialize model manager and check for existing models
  Future<void> initialize() async {
    try {
      _error = null;
      final path = await _getModelPath();
      final file = File(path);

      if (await file.exists()) {
        _modelPath = path;
        _isModelAvailable = true;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to initialize model manager: $e';
      debugPrint(_error);
    }
  }

  /// Download model from remote storage using Dio with real progress tracking
  Future<void> downloadModel() async {
    if (_isDownloading) return;

    try {
      _isDownloading = true;
      _error = null;
      _downloadProgress = 0.0;
      notifyListeners();

      final modelPath = await _getModelPath();
      final dio = Dio();

      // Configure Dio with timeout
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(minutes: 10);

      await dio.download(
        modelDownloadUrl,
        modelPath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            _downloadProgress = received / total;
            notifyListeners();

            // Log progress (first time, every 10%, and last time)
            final percentage = (received / total * 100).toInt();
            if (percentage % 10 == 0 || received == total) {
              debugPrint(
                'Model download: $percentage% ($received / $total bytes)',
              );
            }
          }
        },
      );

      _modelPath = modelPath;
      _isModelAvailable = true;
      _downloadProgress = 1.0;
      notifyListeners();

      debugPrint('Model downloaded successfully to: $modelPath');
    } catch (e) {
      _error = 'Failed to download model: $e';
      _isModelAvailable = false;
      debugPrint(_error);
      notifyListeners();
      rethrow;
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  /// Get the local path where the model should be stored
  Future<String> _getModelPath() async {
    final dir = await getApplicationDocumentsDirectory();
    final modelDir = Directory('${dir.path}/models');

    if (!await modelDir.exists()) {
      await modelDir.create(recursive: true);
    }

    return '${modelDir.path}/$modelFileName';
  }

  /// Delete the downloaded model
  Future<void> deleteModel() async {
    try {
      if (_modelPath != null) {
        final file = File(_modelPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      _modelPath = null;
      _isModelAvailable = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete model: $e';
      debugPrint(_error);
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
