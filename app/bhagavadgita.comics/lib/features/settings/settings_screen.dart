import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/settings_service.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late bool _soundEnabled;
  late bool _musicEnabled;
  late bool _autoDownload;
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _soundEnabled = SettingsService.soundEnabled;
    _musicEnabled = SettingsService.musicEnabled;
    _autoDownload = SettingsService.autoDownload;
    _selectedLanguage = SettingsService.language;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _SectionHeader(title: 'Audio'),
          SwitchListTile(
            title: const Text('Sound Effects'),
            subtitle: const Text('Enable sound effects during playback'),
            value: _soundEnabled,
            activeColor: AppTheme.yellow1,
            onChanged: (value) {
              setState(() => _soundEnabled = value);
              SettingsService.soundEnabled = value;
            },
          ),
          SwitchListTile(
            title: const Text('Background Music'),
            subtitle: const Text('Play background music'),
            value: _musicEnabled,
            activeColor: AppTheme.yellow1,
            onChanged: (value) {
              setState(() => _musicEnabled = value);
              SettingsService.musicEnabled = value;
            },
          ),
          const Divider(),
          _SectionHeader(title: 'Downloads'),
          SwitchListTile(
            title: const Text('Auto Download'),
            subtitle: const Text('Automatically download new episodes'),
            value: _autoDownload,
            activeColor: AppTheme.yellow1,
            onChanged: (value) {
              setState(() => _autoDownload = value);
              SettingsService.autoDownload = value;
            },
          ),
          ListTile(
            title: const Text('Clear Cache'),
            subtitle: const Text('Free up storage space'),
            trailing: const Icon(Icons.cleaning_services),
            onTap: _clearCache,
          ),
          const Divider(),
          _SectionHeader(title: 'Language'),
          ListTile(
            title: const Text('App Language'),
            subtitle: Text(_getLanguageName(_selectedLanguage)),
            trailing: const Icon(Icons.language),
            onTap: _selectLanguage,
          ),
          const Divider(),
          _SectionHeader(title: 'About'),
          ListTile(
            title: const Text('Version'),
            subtitle: const Text('2.0.0'),
            trailing: const Icon(Icons.info_outline),
          ),
          ListTile(
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.description),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.privacy_tip),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'ru':
        return 'Русский';
      case 'hi':
        return 'हिन्दी';
      case 'mr':
        return 'मराठी';
      default:
        return 'English';
    }
  }

  void _selectLanguage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption('en', 'English'),
            _LanguageOption('ru', 'Русский'),
            _LanguageOption('hi', 'हिन्दी'),
            _LanguageOption('mr', 'मराठी'),
          ],
        ),
      ),
    );
  }

  Widget _LanguageOption(String code, String name) {
    return RadioListTile<String>(
      title: Text(name),
      value: code,
      groupValue: _selectedLanguage,
      activeColor: AppTheme.yellow1,
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedLanguage = value);
          SettingsService.language = value;
          Navigator.pop(context);
        }
      },
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear all cached data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.yellow1,
        ),
      ),
    );
  }
}
