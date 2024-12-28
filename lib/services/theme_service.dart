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

  void setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await StorageService.saveThemeMode(mode);
      notifyListeners();
    }
  }
} 