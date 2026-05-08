import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Colors
  static const Color maroon1 = Color(0xFF8B0000);
  static const Color maroon2 = Color(0xFF6B0000);
  static const Color maroon3 = Color(0xFF4B0000);
  static const Color yellow1 = Color(0xFFFFD700);
  static const Color yellow2 = Color(0xFFFFE55C);
  static const Color inactiveYellow = Color(0xFFFFE4B5);
  static const Color backgroundDark = Color(0xFF1A0000);
  static const Color surfaceDark = Color(0xFF2A0000);

  // Aliases for compatibility
  static const Color primaryColor = yellow1;
  static const Color errorColor = Colors.red;

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundDark, maroon3],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [maroon1, maroon2],
  );

  // Text Styles
  static const String fontFamilyProxima = 'Proxima';
  static const String fontFamilyHindi = 'Hindi';
  static const String fontFamilySanskrit = 'Sanskrit';
  static const String fontFamilyDevanagari = 'Devanagari';

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: maroon1,
        secondary: yellow1,
        surface: Colors.white,
        background: Colors.white,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: maroon1,
        onSurface: maroon1,
        onBackground: maroon1,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: maroon1,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: fontFamilyProxima,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: maroon1,
        selectedItemColor: yellow1,
        unselectedItemColor: inactiveYellow,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: _buildTextTheme(maroon1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: yellow1,
          foregroundColor: maroon1,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamilyProxima,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: EdgeInsets.all(8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: maroon1,
        secondary: yellow1,
        surface: surfaceDark,
        background: backgroundDark,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: maroon1,
        onSurface: yellow1,
        onBackground: yellow1,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: maroon1,
        foregroundColor: yellow1,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: fontFamilyProxima,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: yellow1,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: maroon1,
        selectedItemColor: yellow1,
        unselectedItemColor: inactiveYellow,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: _buildTextTheme(yellow1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: yellow1,
          foregroundColor: maroon1,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamilyProxima,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        color: surfaceDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: EdgeInsets.all(8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: yellow1),
        ),
        filled: true,
        fillColor: surfaceDark,
      ),
    );
  }

  static TextTheme _buildTextTheme(Color defaultColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamilyProxima,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: defaultColor,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamilyProxima,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: defaultColor,
      ),
      displaySmall: TextStyle(
        fontFamily: fontFamilyProxima,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: defaultColor,
      ),
      headlineLarge: TextStyle(
        fontFamily: fontFamilyProxima,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: defaultColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamilyProxima,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: defaultColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamilyProxima,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: defaultColor,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamilyProxima,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: defaultColor,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamilyProxima,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: defaultColor,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamilyProxima,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: defaultColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamilyProxima,
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: defaultColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamilyProxima,
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: defaultColor,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamilyProxima,
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: defaultColor,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamilyProxima,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: defaultColor,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamilyProxima,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: defaultColor,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamilyProxima,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: defaultColor,
      ),
    );
  }
}
