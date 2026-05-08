import 'package:flutter/services.dart';
import 'package:flutter_magento/src/services/rada_service.dart' as magento;
import 'package:flutter_magento/src/models/rada_models.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Service for loading and managing RADA files
class RadaService {
  static RadaService? _instance;
  static RadaService get instance => _instance ??= RadaService._();

  RadaService._();

  final magento.RadaService _radaService = magento.RadaService();
  RadaPackage? _currentPackage;

  /// Get the currently loaded RADA package
  RadaPackage? get currentPackage => _currentPackage;

  /// Load RADA file from assets
  Future<RadaPackage> loadFromAssets(String assetPath) async {
    try {
      // Load the asset data
      final byteData = await rootBundle.load(assetPath);

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_rada.rada');

      // Write to temporary file
      await tempFile.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );

      // Extract the RADA archive
      final package = await _radaService.extractArchive(tempFile.path);

      // Clean up temporary file
      await tempFile.delete();

      _currentPackage = package;
      return package;
    } catch (e) {
      throw Exception('Failed to load RADA file: $e');
    }
  }

  /// Load RADA file from file path
  Future<RadaPackage> loadFromFile(String filePath) async {
    try {
      final package = await _radaService.extractArchive(filePath);
      _currentPackage = package;
      return package;
    } catch (e) {
      throw Exception('Failed to load RADA file: $e');
    }
  }

  /// Get archive info without full extraction
  Future<RadaManifest> getArchiveInfo(String filePath) async {
    return await _radaService.getArchiveInfo(filePath);
  }

  /// Validate RADA archive
  Future<bool> validateArchive(String filePath) async {
    return await _radaService.validateArchive(filePath);
  }

  /// Clear loaded package
  void clear() {
    _currentPackage = null;
  }
}
