import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/seasons/seasons_screen.dart';
import '../../features/episode/episode_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/purchase/purchase_screen.dart';
import '../../features/dome/dome_screen.dart';
import '../../features/rada/rada_viewer_screen.dart';

/// Router configuration provider
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/seasons',
        name: 'seasons',
        builder: (context, state) => const SeasonsScreen(),
      ),
      GoRoute(
        path: '/episode/:id',
        name: 'episode',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EpisodeScreen(episodeId: id);
        },
      ),
      GoRoute(
        path: '/dome',
        name: 'dome',
        builder: (context, state) => const DomeScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/purchase',
        name: 'purchase',
        builder: (context, state) => const PurchaseScreen(),
      ),
      GoRoute(
        path: '/rada',
        name: 'rada',
        builder: (context, state) {
          final assetPath = state.uri.queryParameters['asset'];
          final filePath = state.uri.queryParameters['file'];
          return RadaViewerScreen(
            assetPath: assetPath,
            filePath: filePath,
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
});
