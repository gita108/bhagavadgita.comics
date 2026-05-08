import 'package:flutter_magento/flutter_magento.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart';

class MagentoService {
  static FlutterMagento get instance => FlutterMagento.instance;

  /// Preload RADA data from assets
  static Future<void> preloadRADAData() async {
    try {
      // Check if RADA data is already loaded
      final appDir = await getApplicationDocumentsDirectory();
      final radaDir = Directory('${appDir.path}/rada_data');

      if (await radaDir.exists()) {
        print('RADA data already preloaded');
        return;
      }

      print('Starting RADA data preload...');

      // Load RADA file from assets
      final ByteData data = await rootBundle.load('assets/mahabharata.rada');
      final bytes = data.buffer.asUint8List();

      // Extract RADA archive (it's a ZIP file)
      final archive = ZipDecoder().decodeBytes(bytes);

      // Create RADA directory
      await radaDir.create(recursive: true);

      // Extract files
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          final outputFile = File('${radaDir.path}/$filename');
          await outputFile.create(recursive: true);
          await outputFile.writeAsBytes(data);
        } else {
          await Directory('${radaDir.path}/$filename').create(recursive: true);
        }
      }

      print('RADA data preloaded successfully');

      // Register RADA data with Magento service
      await FlutterMagento.instance.registerRADAData(radaDir.path);
    } catch (e) {
      print('Error preloading RADA data: $e');
    }
  }

  /// Get product catalog
  static Future<List<dynamic>> getProducts() async {
    try {
      return await instance.getProducts();
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  /// Get customer cart
  static Future<dynamic> getCart() async {
    try {
      return await instance.getCart();
    } catch (e) {
      print('Error getting cart: $e');
      return null;
    }
  }

  /// Login customer
  static Future<bool> login(String email, String password) async {
    try {
      final result = await instance.login(email, password);
      return result != null;
    } catch (e) {
      print('Error logging in: $e');
      return false;
    }
  }

  /// Logout customer
  static Future<void> logout() async {
    try {
      await instance.logout();
    } catch (e) {
      print('Error logging out: $e');
    }
  }
}
