/// Application configuration and constants
class AppConfig {
  // App Information
  static const String appName = 'Mahabharata';
  static const String appVersion = '2.0.0';
  static const int appBuildNumber = 1;

  // API Configuration
  static const String magentoBaseUrl = 'https://mahabharata.pro/api';
  static const String storeCode = 'default';

  // ICP Configuration
  static const String icpCanisterId = 'rrkah-fqaaa-aaaaa-aaaaq-cai';
  static const ICPNetwork icpNetwork = ICPNetwork.mainnet;

  // Yuku Configuration
  static const String yukuApiKey = 'your_yuku_api_key';

  // Messenger Configuration
  static const String messengerServerUrl = 'wss://messenger.mahabharata.pro';

  // Firebase Configuration
  static const bool enableFirebaseAnalytics = true;
  static const bool enableCrashlytics = true;

  // Feature Flags
  static const bool enableNFTSupport = true;
  static const bool enableMarketplace = true;
  static const bool enableMessenger = true;
  static const bool enableDomeExperience = true;
  static const bool enablePuzzles = true;
  static const bool enableInAppPurchases = true;

  // Content Configuration
  static const String radaAssetPath = 'assets/mahabharata.rada';
  static const Duration downloadTimeout = Duration(minutes: 30);
  static const Duration cacheExpiration = Duration(days: 7);

  // UI Configuration
  static const int maxConcurrentDownloads = 3;
  static const double minZoomScale = 1.0;
  static const double maxZoomScale = 4.0;

  // Analytics Events
  static const String eventEpisodeView = 'episode_view';
  static const String eventEpisodeComplete = 'episode_complete';
  static const String eventQuoteShare = 'quote_share';
  static const String eventMusicPlay = 'music_play';
  static const String eventPuzzleComplete = 'puzzle_complete';
  static const String eventPurchase = 'purchase';
  static const String eventNFTMint = 'nft_mint';
}

enum ICPNetwork { mainnet, testnet }
