import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/settings_service.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for animation
    await Future.delayed(const Duration(seconds: 3));

    // Check if initialized
    if (!mounted) return;

    if (SettingsService.token != null) {
      context.go('/home');
    } else {
      // Still go to home, token will be fetched there
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.maroon1,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon/Logo
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppTheme.yellow1,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.yellow1.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_stories,
                  size: 100,
                  color: AppTheme.maroon1,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Mahabharata',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamilyProxima,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.yellow1,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The Greatest Epic',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamilyProxima,
                  fontSize: 16,
                  color: AppTheme.yellow1.withOpacity(0.8),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 60),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.yellow1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
