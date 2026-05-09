import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_icp/flutter_icp.dart';
import 'package:flutter_magento/flutter_magento.dart';
import 'package:flutter_magento_marketplace/flutter_magento_marketplace.dart';
import 'package:flutter_magento_notifications/flutter_magento_notifications.dart';
import 'package:flutter_uyku/flutter_uyku.dart';
import 'package:flutter_magento_messenger/flutter_magento_messenger.dart';
import 'package:flutter_nft/flutter_nft.dart';

class AppConfig {
  static Future<void> initializeApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    try {
      // Initialize ICP
      await FlutterIcp.initialize(
        baseUrl: 'https://icp-api.example.com',
        apiKey: 'your-icp-api-key',
      );
      
      // Initialize Magento
      await FlutterMagento.initialize(
        baseUrl: 'https://mahabharata-prod.magento.com',
        consumerKey: 'your-magento-consumer-key',
        consumerSecret: 'your-magento-consumer-secret',
        accessToken: 'your-magento-access-token',
        accessTokenSecret: 'your-magento-access-token-secret',
      );
      
      // Initialize Marketplace
      await FlutterMagentoMarketplace.initialize();
      
      // Initialize Notifications
      await FlutterMagentoNotifications.initialize(
        onNotificationReceived: (notification) {
          // Handle notification
          debugPrint('Notification received: ${notification.title}');
        },
      );
      
      // Initialize UYKU
      await FlutterUyku.initialize(
        appId: 'mahabharata-app',
        apiKey: 'your-uyku-api-key',
      );
      
      // Initialize Messenger
      await FlutterMagentoMessenger.initialize(
        appId: 'mahabharata-messenger',
        apiKey: 'your-messenger-api-key',
      );
      
      // Initialize NFT
      await FlutterNft.initialize(
        apiKey: 'your-nft-api-key',
        chainId: 1, // Mainnet
      );
      
      debugPrint('All packages initialized successfully');
    } catch (e) {
      debugPrint('Error initializing app: $e');
      rethrow;
    }
  }
  
  static List<SingleChildWidget> get providers => [
    // Add any providers here
  ];
}
