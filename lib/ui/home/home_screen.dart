import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/bloc/auth_bloc.dart';
import '../../blocs/events/auth_event.dart';
import '../../blocs/states/auth_state.dart';
import 'home_page.dart';
import 'booking_page.dart';
import 'barcode_page.dart';
import 'settings_page.dart';
import '../widgets/app_bar.dart';
import '../widgets/bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // For localization


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode(); // Load theme preference on startup
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<AuthBloc>().add(FetchUserDataRequested(uid)); // Fetch user data
    }
  }

  // Load theme mode from shared preferences
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('themeMode') ?? 'system';
    setState(() {
      if (theme == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (theme == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }
    });
  }

  // Save theme mode to shared preferences
  Future<void> _saveThemeMode(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', theme);
  }

  // Update theme mode based on user selection
  void updateThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
      if (mode == ThemeMode.dark) {
        _saveThemeMode('dark');
      } else if (mode == ThemeMode.light) {
        _saveThemeMode('light');
      } else {
        _saveThemeMode('system');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserDataSuccess) {
            final userData = state.user; // Assign the user data
            return IndexedStack(
              index: _currentIndex,
              children: [
                HomePage(userData: userData), // Pass userData here
                BookingPage(userData: userData), // Pass userData here
                BarcodePage(userData: userData), // Pass userData here
                SettingsPage(userData: userData), // Pass userData here
              ],
            );
          } else if (state is UserDataFailure) {
            return Center(child: Text(state.error));
          } else {
            return  Center(child: Text(AppLocalizations.of(context)!.welcomeMessage));
          }
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

