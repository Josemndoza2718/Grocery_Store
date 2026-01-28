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
        color: AppColors.orange,
        fontSize: 60,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w700,
      ),
      //Sub-Tittle
      titleMedium: TextStyle(
        color: AppColors.orange,
        fontSize: 32,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w700,
      ),
      titleSmall: TextStyle(
        color: AppColors.orange,
        fontSize: 25,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w400,
      ),
      bodyLarge: TextStyle(
        color: AppColors.black,
        fontSize: 18,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w700,
      ),
      //Text
      bodyMedium: TextStyle(
        color: AppColors.black,
        fontSize: 18,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.normal,
      ),
      bodySmall: TextStyle(
        color: AppColors.black,
        fontSize: 15,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.normal,
      ),
      labelLarge: TextStyle(
        color: AppColors.white,
        fontSize: 18,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.normal,
      ),
      //Decoration-Text-Color
      labelMedium: TextStyle(
        color: AppColors.black,
        fontSize: 15,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.normal,
      ),
      //Decoration-Text-Color
      labelSmall: TextStyle(
        color: AppColors.black,
        fontSize: 15,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w700,
      ), 
      displayLarge: TextStyle(
        color: AppColors.black,
        fontSize: 15,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.normal,
      ),
      //Text
      displayMedium: TextStyle(
        color: AppColors.black,
        fontSize: 15,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w500,
      ),
      displaySmall: TextStyle(
        color: AppColors.orange,
        fontSize: 18,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: TextStyle(
        color: AppColors.orange,
        fontSize: 18,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w700,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.orange,
      ),
      headlineMedium: TextStyle(
        color: AppColors.orange,
        fontSize: 18,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: TextStyle(
        color: AppColors.black,
        fontSize: 15,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w700,
      ),
      
    ),
    
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.light,
        primary: AppColors.green,
        secondary: AppColors.green,
        tertiary: const Color(0xFFFFB74D),
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.green,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
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
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
        primary: const Color(0xFF8e2b40),
        secondary: const Color(0xFF8e2b40),
        tertiary: const Color(0xFFf8dd6e),
        surface: const Color(0xFF1e2022),
      ),
      scaffoldBackgroundColor: const Color(0xFF1e2022),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8e2b40),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF344952),
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
          borderSide: const BorderSide(color: Color(0xFF8e2b40), width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
