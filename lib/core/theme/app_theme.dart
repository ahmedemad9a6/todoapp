import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // لون البذرة الأساسي (Indigo حيوي وأنيق يناسب تطبيقات العمل والإنتاجية)
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color primaryDarkColor = Color(0xFF4F46E5);
  static const Color secondaryColor = Color.fromARGB(255, 104, 62, 202);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      brightness: Brightness.light,
      surface: Colors.white,
      surfaceVariant: const Color(0xFFF1F5F9), // Slate 100
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Slate 50 ناعم وعصري
      // خط Cairo العربي لكافة نصوص التطبيق
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.light().textTheme)
          .copyWith(
            headlineMedium: GoogleFonts.cairo(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
            titleLarge: GoogleFonts.cairo(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
            titleMedium: GoogleFonts.cairo(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
            bodyMedium: GoogleFonts.cairo(color: const Color(0xFF334155)),
          ),

      // تخصيص شريط العنوان (AppBar)
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0F172A),
        ),
      ),

      // تخصيص بطاقات المهام (CardThemeData) بحواف 22px ولمسة هوائية خفيفة
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(
            color: Color(0x0F000000), // حدود ناعمة جداً
            width: 1,
          ),
        ),
        color: Colors.white,
      ),

      // تخصيص زر الإضافة العائم (FAB)
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // تخصيص حقول الإدخال (TextFormField)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0x1A000000), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0x12000000), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: const Color(0xFF818CF8),
      secondary: const Color(0xFFA78BFA),
      brightness: Brightness.dark,
      surface: const Color(0xFF1E293B),
      surfaceVariant: const Color(0xFF334155),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(
        0xFF0B0F19,
      ), // Midnight Slate عميق وفخم
      // خط Cairo العربي للوضع الليلي
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            headlineMedium: GoogleFonts.cairo(
              fontWeight: FontWeight.w800,
              color: const Color(0xFFF8FAFC),
              letterSpacing: -0.5,
            ),
            titleLarge: GoogleFonts.cairo(
              fontWeight: FontWeight.w700,
              color: const Color(0xFFF8FAFC),
            ),
            titleMedium: GoogleFonts.cairo(
              fontWeight: FontWeight.w600,
              color: const Color(0xFFE2E8F0),
            ),
            bodyMedium: GoogleFonts.cairo(color: const Color(0xFF94A3B8)),
          ),

      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: const Color(0xFFF8FAFC),
        ),
      ),

      // بطاقات داكنة فاخرة بحدود زجاجية خفيفة
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0x1AFFFFFF), width: 1),
        ),
        color: const Color(0xFF151D2C), // رمادي أزرق داكن ومميز
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF151D2C),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0x2AFFFFFF), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0x1AFFFFFF), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF818CF8), width: 2),
        ),
      ),
    );
  }
}
