import 'package:bungee_ksa/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core package
import 'blocs/bloc/auth_bloc.dart';
import 'repo/auth_repository.dart';
import 'ui/splash.dart';
import 'ui/onboarding/onboarding_screen.dart';
import 'ui/home/home_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository = AuthRepository(); // Initialize Auth Repository

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
        // Add other BLoCs here if needed
      ],
      child: MaterialApp(
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
          '/home': (context) => HomeScreen(),
          // Add more routes as needed
        },
      ),
    );
  }
}
