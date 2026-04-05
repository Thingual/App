import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/picture_model.dart';

/// Service to load and manage picture dataset
class PictureDatasetService {
  static const String _datasetPath =
      'assets/datasets/picture_description_dataset.json';

  List<Picture>? _cachedPictures;

  /// Load all pictures from the dataset
  Future<List<Picture>> loadPictures() async {
    if (_cachedPictures != null) {
      return _cachedPictures!;
    }

    try {
      print('[PictureDatasetService] Loading dataset from: $_datasetPath');
      final jsonString = await rootBundle.loadString(_datasetPath);
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      print(
        '[PictureDatasetService] Loaded ${jsonList.length} pictures from dataset',
      );

      _cachedPictures = jsonList
          .map((item) => Picture.fromJson(item as Map<String, dynamic>))
          .toList();

      print(
        '[PictureDatasetService] Successfully parsed ${_cachedPictures!.length} pictures',
      );
      for (final pic in _cachedPictures!) {
        print(
          '[PictureDatasetService] Picture ${pic.id}: imagePath="${pic.imagePath}"',
        );
      }

      return _cachedPictures!;
    } catch (e) {
      print('[PictureDatasetService] ERROR loading dataset: $e');
      throw Exception('Failed to load picture dataset: $e');
    }
  }

  /// Get a specific picture by ID
  Future<Picture?> getPictureById(int id) async {
    final pictures = await loadPictures();
    try {
      return pictures.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get the first picture (for now, only one is available)
  Future<Picture?> getFirstPicture() async {
    final pictures = await loadPictures();
    return pictures.isNotEmpty ? pictures.first : null;
  }

  /// Clear cache
  void clearCache() {
    _cachedPictures = null;
  }
}
