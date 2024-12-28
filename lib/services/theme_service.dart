import 'package:flutter/material.dart';
import 'storage_service.dart';

class ThemeService extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeService() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> _loadThemeMode() async {
    _themeMode = await StorageService.loadThemeMode();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await StorageService.saveThemeMode(mode);
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    // Reset theme mode to system
    await setThemeMode(ThemeMode.system);
    notifyListeners();
  }
} 