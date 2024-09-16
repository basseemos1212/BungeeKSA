import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme Event
abstract class ThemeEvent {}

class ThemeChanged extends ThemeEvent {
  final ThemeMode themeMode;
  ThemeChanged(this.themeMode);
}

// Theme State
class ThemeState {
  final ThemeMode themeMode;
  ThemeState({required this.themeMode});
}

// Theme Bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc(ThemeMode initialTheme) : super(ThemeState(themeMode: initialTheme)) {
    // Register event handler for ThemeChanged event
    on<ThemeChanged>(_onThemeChanged);
  }

  // Event handler for ThemeChanged
  Future<void> _onThemeChanged(ThemeChanged event, Emitter<ThemeState> emit) async {
    emit(ThemeState(themeMode: event.themeMode));
    await _saveThemeToPrefs(event.themeMode);
  }

  // Save theme mode to SharedPreferences
  Future<void> _saveThemeToPrefs(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    if (themeMode == ThemeMode.dark) {
      await prefs.setString('themeMode', 'dark');
    } else if (themeMode == ThemeMode.light) {
      await prefs.setString('themeMode', 'light');
    } else {
      await prefs.setString('themeMode', 'system');
    }
  }
}
