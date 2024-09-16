import 'package:bungee_ksa/blocs/bloc/settings_bloc.dart';
import 'package:bungee_ksa/firebase_options.dart';
import 'package:bungee_ksa/ui/login_screen.dart';
import 'package:bungee_ksa/ui/widgets/add_class_form.dart';
import 'package:bungee_ksa/ui/widgets/add_class_type_form.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'blocs/bloc/auth_bloc.dart';
import 'blocs/bloc/classes_bloc.dart'; // Add the Classes BLoC
import 'blocs/bloc/theme_bloc.dart';
import 'repo/auth_repository.dart';
import 'ui/home/settings_page.dart';
import 'ui/splash.dart';
import 'ui/onboarding/onboarding_screen.dart';
import 'ui/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase

  final ThemeMode initialThemeMode = await loadThemeMode(); // Load theme mode from SharedPreferences

  runApp(MyApp(initialThemeMode: initialThemeMode));
}

// Load theme mode from SharedPreferences
Future<ThemeMode> loadThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final theme = prefs.getString('themeMode') ?? 'system';
  if (theme == 'dark') {
    return ThemeMode.dark;
  } else if (theme == 'light') {
    return ThemeMode.light;
  } else {
    return ThemeMode.system;
  }
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository = AuthRepository();
  final ThemeMode initialThemeMode;

  MyApp({super.key, required this.initialThemeMode});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
        BlocProvider<ClassesBloc>(
          create: (context) => ClassesBloc(),
        ),
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc(initialThemeMode),
        ),
        BlocProvider(create: (context)=> SettingsBloc())
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Bungee KSA',
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light().copyWith(
              textTheme: GoogleFonts.bebasNeueTextTheme(
                Theme.of(context).textTheme,
              ),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4d8785),
                secondary: const Color(0xFF6dc0bd),
                background: const Color(0xFFe5f6ef),
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              textTheme: GoogleFonts.bebasNeueTextTheme(
                Theme.of(context).textTheme,
              ),
              colorScheme: ColorScheme.dark(
                primary: const Color(0xFF4d8785),
                secondary: const Color(0xFF6dc0bd),
                background: const Color(0xFF2d2d2d),
              ),
            ),
            themeMode: state.themeMode, // Apply the theme mode from Bloc
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/home': (context) => const HomeScreen(),
              '/login': (context) => LoginScreen(),
              '/add-class': (context) => const AddClassScreen(),
              '/add-class-type': (context) => AddClassTypeScreen(),
            },
          );
        },
      ),
    );
  }
}
