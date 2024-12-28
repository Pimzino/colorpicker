import 'package:flutter/material.dart';
import 'storage_service.dart';

class ThemeService extends ChangeNotifier {
  ThemeMode _themeMode;

  ThemeService() : _themeMode = StorageService.loadThemeMode();

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await StorageService.saveThemeMode(mode);
      notifyListeners();
    }
  }
} 