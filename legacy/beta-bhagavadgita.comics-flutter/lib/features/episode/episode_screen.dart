import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/comics_scroll_viewer.dart';

class EpisodeScreen extends ConsumerStatefulWidget {
  final String episodeId;

  const EpisodeScreen({
    super.key,
    required this.episodeId,
  });

  @override
  ConsumerState<EpisodeScreen> createState() => _EpisodeScreenState();
}

class _EpisodeScreenState extends ConsumerState<EpisodeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ComicsScrollViewer(
        comicsFilePath: 'files/Ch${widget.episodeId}_Book01.comics',
        episodeTitle: 'Episode ${widget.episodeId}',
      ),
    );
  }
}
