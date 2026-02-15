import 'package:flutter/material.dart';
import 'app_colors.dart';

/// PNU Basketball Platform - Theme Configuration
/// 
/// 앱 전체의 테마를 한 곳에서 관리합니다.
/// 모든 위젯은 이 테마를 자동으로 상속받습니다.
class AppTheme {
  AppTheme._(); // private constructor

  /// 라이트 테마 (기본 테마)
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      
      // ===== Primary Colors =====
      primaryColor: AppColors.activeBlue,
      scaffoldBackgroundColor: AppColors.pageBg,
      
      // ===== AppBar Theme (모든 AppBar에 자동 적용) =====
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundWhite,
        foregroundColor: AppColors.titleText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.titleText,
        ),
        iconTheme: IconThemeData(
          color: AppColors.titleText,
        ),
      ),
      
      // ===== BottomNavigationBar Theme (자동 적용) =====
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundWhite,
        selectedItemColor: AppColors.activeBlue,
        unselectedItemColor: AppColors.subText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
      
      // ===== Card Theme (자동 적용) =====
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: AppColors.backgroundWhite,
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      ),
      
      // ===== ElevatedButton Theme (자동 적용) =====
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.activeBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // ===== TextButton Theme =====
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.activeBlue,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // ===== OutlinedButton Theme =====
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.titleText,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      
      // ===== Chip Theme (FilterChip 등) =====
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.backgroundWhite,
        selectedColor: AppColors.activeBlue,
        labelStyle: const TextStyle(
          fontSize: 13,
          color: AppColors.titleText,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 13,
          color: AppColors.backgroundWhite,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      
      // ===== Input Decoration Theme (TextField) =====
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.activeBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // ===== Divider Theme =====
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      
      // ===== Color Scheme =====
      colorScheme: const ColorScheme.light(
        primary: AppColors.activeBlue,
        secondary: AppColors.pointCyan,
        error: AppColors.errorRed,
        surface: AppColors.backgroundWhite,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
        onSurface: AppColors.titleText,
      ),
      
      // ===== Text Theme =====
      textTheme: const TextTheme(
        // Display (큰 제목)
        displayLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.titleText,
        ),
        
        // Title (화면 제목)
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.titleText,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.titleText,
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.titleText,
        ),
        
        // Body (본문)
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.titleText,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.titleText,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: AppColors.subText,
        ),
        
        // Label (버튼, 태그)
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.titleText,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.titleText,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.subText,
        ),
      ),
    );
  }
}
