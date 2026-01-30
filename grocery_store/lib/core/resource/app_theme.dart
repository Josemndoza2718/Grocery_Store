// lib/config/app_theme.dart

import 'package:flutter/material.dart';
import 'package:grocery_store/core/resource/colors.dart';

class AppTheme {
  // Tema claro
  static ThemeData get lightTheme {
    return ThemeData(
      textTheme: const TextTheme(
        //Tittle
        titleLarge: TextStyle(
          color: AppColors.black,
          fontSize: 24,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.w700,
        ),
        //Sub-Tittle
        titleMedium: TextStyle(
          color: AppColors.darkgreen,
          fontSize: 24,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.w700,
        ),
        titleSmall: TextStyle(
          color: AppColors.darkgreen,
          fontSize: 18,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: AppColors.black,
          fontSize: 18,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: TextStyle(
          color: AppColors.black,
          fontSize: 18,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: AppColors.black,
          fontSize: 15,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.normal,
        ),
        labelLarge: TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.w700,
        ),
        //Decoration-Text-Color
        labelMedium: TextStyle(
          color: AppColors.black,
          fontSize: 15,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.w700,
        ),
        //Decoration-Text-Color
        labelSmall: TextStyle(
          color: AppColors.black,
          fontSize: 15,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.normal,
        ),
        displayLarge: TextStyle(
          color: AppColors.black,
          fontSize: 15,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.normal,
        ),
        //Text
        displayMedium: TextStyle(
          color: AppColors.black,
          fontSize: 15,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.w500,
        ),
        displaySmall: TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: TextStyle(
          color: AppColors.grey,
          fontSize: 18,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.normal,
          // decoration: TextDecoration.underline,
          // decorationColor: AppColors.orange,
        ),
        headlineMedium: TextStyle(
          color: AppColors.orange,
          fontSize: 18,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: TextStyle(
          color: AppColors.black,
          fontSize: 15,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.w700,
        ),
      ),
      useMaterial3: true,
      fontFamily: 'CreatoDisplay',
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.green,
        brightness: Brightness.light,
        primary: AppColors.green,
        secondary: AppColors.green,
        tertiary: AppColors.orange,
        surface: AppColors.lightwhite,
      ),
      scaffoldBackgroundColor: AppColors.white,
      canvasColor: AppColors.green,
      cardColor: AppColors.white,
      expansionTileTheme: const ExpansionTileThemeData(
        backgroundColor: AppColors.white,
      ),
      
      searchBarTheme: const SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll(AppColors.white),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.green,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E1E1E),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xfff2f5f7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.green, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.black54),
      ),
    );
  }

  // Tema oscuro
  static ThemeData get darkTheme {
    return ThemeData(
      textTheme: const TextTheme(
        //Title
        titleLarge: TextStyle(
          color: AppColors.white,
          fontSize: 24,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.w700,
        ),
        //Sub-Title
        titleMedium: TextStyle(
          color: AppColors.lightgreen,
          fontSize: 24,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.w700,
        ),
        titleSmall: TextStyle(
          color: AppColors.darkgreen,
          fontSize: 18,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: AppColors.lightwhite,
          fontSize: 18,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: TextStyle(
          color: AppColors.black,
          fontSize: 18,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: AppColors.lightwhite,
          fontSize: 15,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.normal,
        ),
        labelLarge: TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.w700,
        ),
        labelMedium: TextStyle(
          color: AppColors.lightwhite,
          fontSize: 15,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.w700,
        ),
        labelSmall: TextStyle(
          color: AppColors.lightwhite,
          fontSize: 15,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.normal,
        ),
        displayLarge: TextStyle(
          color: AppColors.lightwhite,
          fontSize: 15,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.normal,
        ),
        displayMedium: TextStyle(
          color: AppColors.lightwhite,
          fontSize: 15,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.w500,
        ),
        displaySmall: TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: TextStyle(
          color: AppColors.grey,
          fontSize: 18,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.normal,
          // decoration: TextDecoration.underline,
          // decorationColor: AppColors.orange,
        ),
        headlineMedium: TextStyle(
          color: AppColors.orange,
          fontSize: 18,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: TextStyle(
          color: AppColors.black,
          fontSize: 15,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.w700,
        ),
      ),
      useMaterial3: true,
      fontFamily: 'CreatoDisplay',
      brightness: Brightness.dark,
      canvasColor: AppColors.lightblack, //const Color(0xFF1E1E1E),
      cardColor: AppColors.lightblack,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.green,
        brightness: Brightness.dark,
        primary: AppColors.green,
        onPrimary: AppColors.white,
        secondary: AppColors.lightgreen,
        onSecondary: AppColors.white,
        tertiary: const Color(0xFFFFB74D),
        surface: const Color(0xFF1E1E1E),
        onSurface: AppColors.lightwhite,
        error: AppColors.red,
        onError: AppColors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      expansionTileTheme: const ExpansionTileThemeData(
        backgroundColor: Color(0xFF1E1E1E),
      ),
      searchBarTheme: const SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll(AppColors.lightblack),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontFamily: 'CreatoDisplay',
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.green, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white54),
      ),
    );
  }
}
