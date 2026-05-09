import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:archive/archive.dart';

import '../config/app_config.dart';
import 'analytics_service.dart';

/// Состояние загрузки
enum DownloadState {
  idle,
  downloading,
  extracting,
  completed,
  error,
}

/// Информация о загрузке
class DownloadInfo {
  final String id;
  final String url;
  final String savePath;
  final DownloadState state;
  final double progress;
  final String? error;
  final int downloadedBytes;
  final int totalBytes;

  DownloadInfo({
    required this.id,
    required this.url,
    required this.savePath,
    this.state = DownloadState.idle,
    this.progress = 0.0,
    this.error,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
  });

  DownloadInfo copyWith({
    String? id,
    String? url,
    String? savePath,
    DownloadState? state,
    double? progress,
    String? error,
    int? downloadedBytes,
    int? totalBytes,
  }) {
    return DownloadInfo(
      id: id ?? this.id,
      url: url ?? this.url,
      savePath: savePath ?? this.savePath,
      state: state ?? this.state,
      progress: progress ?? this.progress,
      error: error ?? this.error,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
    );
  }

  bool get isDownloading => state == DownloadState.downloading;
  bool get isCompleted => state == DownloadState.completed;
  bool get hasError => state == DownloadState.error;
}

/// Сервис для загрузки файлов
/// Аналог BackgroundDownloader из legacy iOS приложения
class DownloadService extends ChangeNotifier {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  static DownloadService get instance => _instance;

  final Dio _dio = Dio();
  final Map<String, DownloadInfo> _downloads = {};
  final Map<String, CancelToken> _cancelTokens = {};

  /// Получить информацию о загрузке
  DownloadInfo? getDownloadInfo(String id) => _downloads[id];

  /// Получить все активные загрузки
  List<DownloadInfo> get activeDownloads => _downloads.values
      .where((d) =>
          d.state == DownloadState.downloading ||
          d.state == DownloadState.extracting)
      .toList();

  /// Получить все завершенные загрузки
  List<DownloadInfo> get completedDownloads => _downloads.values
      .where((d) => d.state == DownloadState.completed)
      .toList();

  /// Скачать файл
  Future<String> downloadFile({
    required String id,
    required String url,
    String? fileName,
    bool extractZip = false,
    Function(double progress)? onProgress,
  }) async {
    try {
      // Получить директорию для сохранения
      final directory = await getApplicationDocumentsDirectory();
      final savePath =
          '${directory.path}/${fileName ?? _getFileNameFromUrl(url)}';

      // Создать запись о загрузке
      _downloads[id] = DownloadInfo(
        id: id,
        url: url,
        savePath: savePath,
        state: DownloadState.downloading,
      );
      notifyListeners();

      // Логировать начало загрузки
      await AnalyticsService.instance.logDownloadStart('file', id);

      // Создать токен отмены
      final cancelToken = CancelToken();
      _cancelTokens[id] = cancelToken;

      // Скачать файл
      await _dio.download(
        url,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            _downloads[id] = _downloads[id]!.copyWith(
              progress: progress,
              downloadedBytes: received,
              totalBytes: total,
            );
            onProgress?.call(progress);
            notifyListeners();
          }
        },
      );

      // Если нужно распаковать
      String finalPath = savePath;
      if (extractZip && savePath.endsWith('.zip')) {
        _downloads[id] = _downloads[id]!.copyWith(
          state: DownloadState.extracting,
        );
        notifyListeners();

        finalPath = await _extractZipFile(savePath);

        // Удалить zip файл после распаковки
        final zipFile = File(savePath);
        if (await zipFile.exists()) {
          await zipFile.delete();
        }
      }

      // Отметить как завершенную
      _downloads[id] = _downloads[id]!.copyWith(
        state: DownloadState.completed,
        progress: 1.0,
        savePath: finalPath,
      );
      notifyListeners();

      // Логировать завершение
      final file = File(finalPath);
      final fileSize = await file.length();
      await AnalyticsService.instance.logDownloadComplete('file', id, fileSize);

      _cancelTokens.remove(id);

      return finalPath;
    } catch (e) {
      debugPrint('Error downloading file: $e');

      _downloads[id] = _downloads[id]?.copyWith(
            state: DownloadState.error,
            error: e.toString(),
          ) ??
          DownloadInfo(
            id: id,
            url: url,
            savePath: '',
            state: DownloadState.error,
            error: e.toString(),
          );
      notifyListeners();

      _cancelTokens.remove(id);
      rethrow;
    }
  }

  /// Отменить загрузку
  Future<void> cancelDownload(String id) async {
    final cancelToken = _cancelTokens[id];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('Download cancelled by user');
    }

    _downloads.remove(id);
    _cancelTokens.remove(id);
    notifyListeners();
  }

  /// Удалить загруженный файл
  Future<void> deleteDownload(String id) async {
    final download = _downloads[id];
    if (download != null && download.isCompleted) {
      final file = File(download.savePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Если это директория (был распакован архив)
      final directory = Directory(download.savePath);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }

      _downloads.remove(id);
      notifyListeners();
    }
  }

  /// Проверить, загружен ли файл
  Future<bool> isDownloaded(String id) async {
    final download = _downloads[id];
    if (download == null || !download.isCompleted) {
      return false;
    }

    final file = File(download.savePath);
    if (await file.exists()) {
      return true;
    }

    final directory = Directory(download.savePath);
    return await directory.exists();
  }

  /// Получить путь к загруженному файлу
  String? getDownloadedFilePath(String id) {
    final download = _downloads[id];
    return download?.isCompleted == true ? download?.savePath : null;
  }

  /// Извлечь имя файла из URL
  String _getFileNameFromUrl(String url) {
    final uri = Uri.parse(url);
    return uri.pathSegments.last;
  }

  /// Распаковать ZIP файл
  Future<String> _extractZipFile(String zipPath) async {
    try {
      // Прочитать ZIP файл
      final bytes = File(zipPath).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Определить директорию для распаковки
      final outputDir = zipPath.replaceAll('.zip', '');
      final directory = Directory(outputDir);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Распаковать файлы
      for (final file in archive) {
        final filename = '$outputDir/${file.name}';

        if (file.isFile) {
          final outFile = File(filename);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        } else {
          final dir = Directory(filename);
          await dir.create(recursive: true);
        }
      }

      return outputDir;
    } catch (e) {
      debugPrint('Error extracting ZIP file: $e');
      rethrow;
    }
  }

  /// Очистить все завершенные загрузки
  void clearCompleted() {
    _downloads.removeWhere((key, value) => value.isCompleted);
    notifyListeners();
  }

  /// Очистить все загрузки с ошибками
  void clearErrors() {
    _downloads.removeWhere((key, value) => value.hasError);
    notifyListeners();
  }
}
