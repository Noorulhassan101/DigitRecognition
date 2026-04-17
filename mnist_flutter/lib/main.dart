import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/api_service.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiService()),
      ],
      child: const MnistApp(),
    ),
  );
}

class MnistApp extends StatelessWidget {
  const MnistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MNIST Digit Recognizer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Tailwind Slate 900
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6), // Blue 500
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E293B), // Slate 800
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1.5),
          ),
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.5),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
