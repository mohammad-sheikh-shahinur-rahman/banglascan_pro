
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  double _speechRate = 0.5;

  ThemeMode get themeMode => _themeMode;
  double get speechRate => _speechRate;

  SettingsProvider() {
    _loadSettings();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Theme
    String? themeStr = prefs.getString('theme_mode');
    if (themeStr == 'Light') _themeMode = ThemeMode.light;
    else if (themeStr == 'Dark') _themeMode = ThemeMode.dark;
    else _themeMode = ThemeMode.system;

    // Load Speech Rate
    _speechRate = prefs.getDouble('speech_rate') ?? 0.5;
    
    notifyListeners();
  }

  void setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode);
    
    if (mode == 'Light') _themeMode = ThemeMode.light;
    else if (mode == 'Dark') _themeMode = ThemeMode.dark;
    else _themeMode = ThemeMode.system;

    notifyListeners();
  }

  void setSpeechRate(double rate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('speech_rate', rate);
    _speechRate = rate;
    notifyListeners();
  }
}
