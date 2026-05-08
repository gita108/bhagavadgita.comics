import 'package:flutter/material.dart';
import 'package:flutter_magento/src/models/rada_models.dart';
import '../../core/services/rada_service.dart';
import '../../core/theme/app_theme.dart';

/// Screen for viewing RADA package content
class RadaViewerScreen extends StatefulWidget {
  final String? assetPath;
  final String? filePath;

  const RadaViewerScreen({
    super.key,
    this.assetPath,
    this.filePath,
  });

  @override
  State<RadaViewerScreen> createState() => _RadaViewerScreenState();
}

class _RadaViewerScreenState extends State<RadaViewerScreen> {
  bool _isLoading = true;
  RadaPackage? _package;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRadaFile();
  }

  Future<void> _loadRadaFile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final radaService = RadaService.instance;
      RadaPackage package;

      if (widget.assetPath != null) {
        package = await radaService.loadFromAssets(widget.assetPath!);
      } else if (widget.filePath != null) {
        package = await radaService.loadFromFile(widget.filePath!);
      } else {
        throw Exception('No RADA file path provided');
      }

      setState(() {
        _package = package;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RADA Viewer'),
        backgroundColor: AppTheme.maroon1,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.yellow1,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading RADA file',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadRadaFile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_package == null) {
      return const Center(
        child: Text('No RADA package loaded'),
      );
    }

    return _buildPackageView(_package!);
  }

  Widget _buildPackageView(RadaPackage package) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RADA Package Loaded',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.yellow1,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Successfully loaded RADA format content.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Available locales: ${package.availableLocales.join(", ")}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
