import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/services/comics_service.dart';
import '../../../core/theme/app_theme.dart';

/// Виджет для просмотра комиксов с вертикальным скроллом (как в legacy версии)
class ComicsScrollViewer extends StatefulWidget {
  final String comicsFilePath;
  final String episodeTitle;

  const ComicsScrollViewer({
    super.key,
    required this.comicsFilePath,
    required this.episodeTitle,
  });

  @override
  State<ComicsScrollViewer> createState() => _ComicsScrollViewerState();
}

class _ComicsScrollViewerState extends State<ComicsScrollViewer>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List<ComicsLayer> _layers = [];
  Map<String, dynamic>? _metadata;
  bool _isLoading = true;
  String? _error;
  bool _showControls = true;

  // Для отслеживания видимых слоев
  final Set<int> _loadedLayers = {};
  double _comicsWidth = 0;
  double _comicsHeight = 0;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _loadComics();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadComics() async {
    try {
      final comicsService = Provider.of<ComicsService>(context, listen: false);

      // Загружаем метаданные
      _metadata = await comicsService.getComicsMetadata(widget.comicsFilePath);

      // Загружаем информацию о слоях
      final layersData =
          await comicsService.getComicsLayers(widget.comicsFilePath);

      if (layersData.isEmpty) {
        // Если слои не найдены, создаем демо-слои
        _layers = _createDemoLayers();
      } else {
        _layers = layersData;
      }

      // Получаем размеры комикса
      if (_metadata != null && _metadata!['width'] != null) {
        _comicsWidth = (_metadata!['width'] as num).toDouble();
        _comicsHeight = (_metadata!['height'] as num).toDouble();
      } else {
        // Значения по умолчанию
        _comicsWidth = 1080;
        _comicsHeight = 15000; // Приблизительная высота
      }

      // Вычисляем масштаб для подгонки по ширине экрана
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final screenWidth = MediaQuery.of(context).size.width;
        setState(() {
          _scale = screenWidth / _comicsWidth;
          _isLoading = false;
        });
        _fadeController.forward();
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки комикса: $e';
        _isLoading = false;
      });
    }
  }

  List<ComicsLayer> _createDemoLayers() {
    // Создаем демо-слои для демонстрации
    final demoLayers = <ComicsLayer>[];
    for (int i = 0; i < 20; i++) {
      demoLayers.add(ComicsLayer(
        index: i,
        imagePath: 'assets/images/layer_$i.png',
        y: i * 800.0,
        height: 800.0,
        width: 1080.0,
        alpha: 1.0,
      ));
    }
    return demoLayers;
  }

  void _onScroll() {
    // Проверяем какие слои сейчас видимы и загружаем их
    final scrollOffset = _scrollController.offset / _scale;
    final viewportHeight = MediaQuery.of(context).size.height / _scale;

    // Область с запасом (3x высоты экрана)
    final visibleTop = scrollOffset - viewportHeight;
    final visibleBottom = scrollOffset + viewportHeight * 2;

    setState(() {
      for (var layer in _layers) {
        final layerTop = layer.y;
        final layerBottom = layer.y + layer.height;

        // Проверяем пересечение с видимой областью
        if (layerBottom >= visibleTop && layerTop <= visibleBottom) {
          _loadedLayers.add(layer.index);
        } else {
          // Выгружаем слои вне видимой области
          _loadedLayers.remove(layer.index);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_error != null) {
      return _buildErrorWidget();
    }

    return _buildComicsViewer();
  }

  Widget _buildLoadingWidget() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
            SizedBox(height: 16),
            Text(
              'Загрузка комикса...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Ошибка загрузки',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadComics,
                icon: const Icon(Icons.refresh),
                label: const Text('Повторить'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComicsViewer() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Основной скролл комикса
            _buildScrollView(),

            // Элементы управления
            if (_showControls) _buildControls(),

            // Индикатор прогресса
            if (_showControls) _buildScrollIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollView() {
    return Container(
      color: Colors.black,
      child: InteractiveViewer(
        minScale: _scale,
        maxScale: _scale * 2,
        constrained: false,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: _comicsHeight * _scale,
            child: Stack(
              children: _layers.map((layer) {
                // Загружаем только видимые слои
                final isLoaded = _loadedLayers.contains(layer.index);

                return Positioned(
                  left: 0,
                  top: layer.y * _scale,
                  width: MediaQuery.of(context).size.width,
                  height: layer.height * _scale,
                  child: Opacity(
                    opacity: layer.alpha,
                    child: isLoaded
                        ? _buildLayer(layer)
                        : Container(color: Colors.black),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLayer(ComicsLayer layer) {
    return FutureBuilder<Uint8List?>(
      future: _getLayerImage(layer.imagePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.grey[900],
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.contain,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholderLayer(layer);
            },
          );
        }

        return _buildPlaceholderLayer(layer);
      },
    );
  }

  Widget _buildPlaceholderLayer(ComicsLayer layer) {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image,
              size: 40,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 8),
            Text(
              'Layer ${layer.index + 1}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Кнопка назад
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 8),

              // Название эпизода
              Expanded(
                child: Text(
                  widget.episodeTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 8),

              // Кнопка настроек
              IconButton(
                onPressed: _showSettings,
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScrollIndicator() {
    final scrollProgress = _scrollController.hasClients
        ? (_scrollController.offset /
                _scrollController.position.maxScrollExtent)
            .clamp(0.0, 1.0)
        : 0.0;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Прогресс бар
              Row(
                children: [
                  Text(
                    '${(scrollProgress * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: scrollProgress,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Настройки просмотра',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.straighten),
              title: const Text('Масштаб'),
              subtitle: Text('${(_scale * 100).round()}%'),
              trailing: SizedBox(
                width: 150,
                child: Slider(
                  value: _scale,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  label: '${(_scale * 100).round()}%',
                  onChanged: (value) {
                    setState(() {
                      _scale = value;
                    });
                  },
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Информация о комиксе'),
              subtitle: Text('${_layers.length} слоев'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _showComicsInfo();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showComicsInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.episodeTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Ширина', '${_comicsWidth.toInt()} px'),
            _buildInfoRow('Высота', '${_comicsHeight.toInt()} px'),
            _buildInfoRow('Слоев', '${_layers.length}'),
            _buildInfoRow('Загружено', '${_loadedLayers.length}'),
            _buildInfoRow('Масштаб', '${(_scale * 100).round()}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  /// Получение изображения слоя из архива
  Future<Uint8List?> _getLayerImage(String imagePath) async {
    try {
      final comicsService = Provider.of<ComicsService>(context, listen: false);
      return await comicsService.getLayerImage(
          widget.comicsFilePath, imagePath);
    } catch (e) {
      print('Ошибка получения изображения слоя: $e');
      return null;
    }
  }
}

/// Модель слоя комикса
class ComicsLayer {
  final int index;
  final String imagePath;
  final double y;
  final double height;
  final double width;
  final double alpha;

  ComicsLayer({
    required this.index,
    required this.imagePath,
    required this.y,
    required this.height,
    required this.width,
    this.alpha = 1.0,
  });
}
