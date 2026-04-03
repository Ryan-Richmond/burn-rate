import 'package:flutter/material.dart';

import 'meeting_cost_screen.dart';

class BurnRateApp extends StatelessWidget {
  const BurnRateApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
    );

    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFF59E0B),
      brightness: Brightness.dark,
      surface: const Color(0xFF131A23),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Burn Rate',
      theme: baseTheme.copyWith(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFF070B11),
        textTheme: baseTheme.textTheme.copyWith(
          displaySmall: baseTheme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -1.3,
          ),
          headlineMedium: baseTheme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
          titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(
            color: const Color(0xFFD4D9E1),
            height: 1.45,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: const Color(0xFF111822),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0B121A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
          ),
          labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: colorScheme.primary,
            foregroundColor: const Color(0xFF140B00),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
      home: const MeetingCostScreen(),
    );
  }
}
