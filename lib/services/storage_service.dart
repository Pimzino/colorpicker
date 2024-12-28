import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/color_history_entry.dart';
import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class StorageService {
  static const String _themeKey = 'theme_mode';
  static const String _hotkeyModifiersKey = 'hotkey_modifiers';
  static const String _hotkeyMainKeyKey = 'hotkey_main_key';
  static const String _colorHistoryKey = 'color_history';
  static const int _maxHistorySize = 100;

  // Theme Mode
  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.toString());
  }
  
  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final String? modeStr = prefs.getString(_themeKey);
    if (modeStr == null) return ThemeMode.system;
    
    return ThemeMode.values.firstWhere(
      (mode) => mode.toString() == modeStr,
      orElse: () => ThemeMode.system,
    );
  }
  
  // Hotkey
  static Future<void> saveHotkey(HotKey hotkey) async {
    final prefs = await SharedPreferences.getInstance();
    final modifiers = hotkey.modifiers?.map((m) => m.toString()).toList() ?? [];
    await prefs.setStringList(_hotkeyModifiersKey, modifiers);
    await prefs.setString(_hotkeyMainKeyKey, hotkey.keyCode.toString());
  }
  
  static Future<HotKey> loadHotkey() async {
    final prefs = await SharedPreferences.getInstance();
    final modifierStrs = prefs.getStringList(_hotkeyModifiersKey);
    final mainKeyStr = prefs.getString(_hotkeyMainKeyKey);
    
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

  // Color History
  static Future<List<ColorHistoryEntry>> loadColorHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_colorHistoryKey);
    if (jsonString == null) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => ColorHistoryEntry.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error loading color history: $e');
      return [];
    }
  }

  static Future<void> addColorToHistory(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await loadColorHistory();

    // Add new entry at the beginning
    history.insert(
      0,
      ColorHistoryEntry(
        color: color,
        timestamp: DateTime.now(),
      ),
    );

    // Limit history size
    if (history.length > _maxHistorySize) {
      history.removeRange(_maxHistorySize, history.length);
    }

    // Save to storage with newest first
    await prefs.setString(
      _colorHistoryKey,
      json.encode(history.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> clearColorHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_colorHistoryKey);
  }

  static Future<void> removeFromHistory(ColorHistoryEntry entryToRemove) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await loadColorHistory();

    history.removeWhere(
      (entry) => 
        entry.color.value == entryToRemove.color.value && 
        entry.timestamp.isAtSameMomentAs(entryToRemove.timestamp)
    );

    // Save to storage with newest first
    await prefs.setString(
      _colorHistoryKey,
      json.encode(history.map((e) => e.toJson()).toList()),
    );
  }
} 