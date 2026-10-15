import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/difficulty_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Set preferred system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const SystemNumberGuessingApp());
}

class SystemNumberGuessingApp extends StatelessWidget {
  const SystemNumberGuessingApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Custom tailored Lavender & Deep Purple Material 3 Color Palette
    const primaryDeepPurple = Color(0xFF4A148C); // Deep purple
    const secondaryPurple = Color(0xFF5E35B1);   // Medium rich purple
    const accentPurple = Color(0xFF7C4DFF);      // Vibrant accent
    const lavenderBackground = Color(0xFFF7F3FB);// Soft light lavender
    const surfaceWhite = Color(0xFFFFFFFF);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryDeepPurple,
      primary: primaryDeepPurple,
      secondary: secondaryPurple,
      tertiary: accentPurple,
      surface: surfaceWhite,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'System Number Guessing Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: lavenderBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: lavenderBackground,
          foregroundColor: primaryDeepPurple,
          elevation: 0,
          scrolledUnderElevation: 1.5,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primaryDeepPurple,
            letterSpacing: 0.3,
          ),
        ),
        cardTheme: CardThemeData(
          color: surfaceWhite,
          elevation: 2,
          shadowColor: primaryDeepPurple.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      home: const DifficultyScreen(),
    );
  }
}
