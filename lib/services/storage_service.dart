import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class StorageService {
  static const String _themeKey = 'theme_mode';
  static const String _hotkeyModifiersKey = 'hotkey_modifiers';
  static const String _hotkeyMainKeyKey = 'hotkey_main_key';
  
  static late final SharedPreferences _prefs;
  
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Theme Mode
  static Future<void> saveThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeKey, mode.toString());
  }
  
  static ThemeMode loadThemeMode() {
    final String? modeStr = _prefs.getString(_themeKey);
    if (modeStr == null) return ThemeMode.system;
    
    return ThemeMode.values.firstWhere(
      (mode) => mode.toString() == modeStr,
      orElse: () => ThemeMode.system,
    );
  }
  
  // Hotkey
  static Future<void> saveHotkey(HotKey hotkey) async {
    final modifiers = hotkey.modifiers?.map((m) => m.toString()).toList() ?? [];
    await _prefs.setStringList(_hotkeyModifiersKey, modifiers);
    await _prefs.setString(_hotkeyMainKeyKey, hotkey.keyCode.toString());
  }
  
  static HotKey loadHotkey() {
    final modifierStrs = _prefs.getStringList(_hotkeyModifiersKey);
    final mainKeyStr = _prefs.getString(_hotkeyMainKeyKey);
    
    if (mainKeyStr == null) {
      // Default hotkey: Ctrl + Shift + P
      return HotKey(
        KeyCode.keyP,
        modifiers: [KeyModifier.control, KeyModifier.shift],
      );
    }
    
    final modifiers = modifierStrs?.map((str) {
      return KeyModifier.values.firstWhere(
        (m) => m.toString() == str,
        orElse: () => KeyModifier.control,
      );
    }).toList() ?? [];
    
    final mainKey = KeyCode.values.firstWhere(
      (k) => k.toString() == mainKeyStr,
      orElse: () => KeyCode.keyP,
    );
    
    return HotKey(mainKey, modifiers: modifiers);
  }
} 