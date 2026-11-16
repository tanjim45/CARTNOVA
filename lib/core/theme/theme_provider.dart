import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider =
    StateNotifierProvider<ThemeController, ThemeMode>((ref) {
  return ThemeController();
});

class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system) {
    _loadTheme();
  }

  static const String _themeKey = 'cartnova_theme_mode';

  Future<void> _loadTheme() async {
    try {
      final preferences = await SharedPreferences.getInstance();

      final savedTheme = preferences.getString(_themeKey);

      if (savedTheme == 'light') {
        state = ThemeMode.light;
      } else if (savedTheme == 'dark') {
        state = ThemeMode.dark;
      } else {
        state = ThemeMode.system;
      }
    } catch (e) {
      debugPrint('Theme loading failed: $e');
    }
  }

  Future<void> changeTheme(ThemeMode themeMode) async {
    state = themeMode;

    try {
      final preferences = await SharedPreferences.getInstance();

      await preferences.setString(
        _themeKey,
        themeMode.name,
      );
    } catch (e) {
      debugPrint('Theme saving failed: $e');
    }
  }
}
