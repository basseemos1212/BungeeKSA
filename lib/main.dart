import 'package:bungee_ksa/ui/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ui/splash.dart';
import 'ui/onboarding/onboarding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bungee KSA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Global text theme using Bebas Neue
        textTheme: GoogleFonts.bebasNeueTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4d8785), // Primary brand color (dark turquoise)
          secondary: const Color(0xFF6dc0bd), // Secondary brand color (light turquoise)
          background: const Color(0xFFe5f6ef), // Background color (light green)
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/onboarding': (context) => OnboardingScreen(),
        // Add home screen route when ready
        '/home': (context) =>  HomeScreen(), // Placeholder for your main screen
      },
    );
  }
}
