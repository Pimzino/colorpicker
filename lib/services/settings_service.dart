import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  HotKey _togglePickerHotKey = HotKey(
    KeyCode.keyP,
    modifiers: [KeyModifier.control, KeyModifier.shift],
    scope: HotKeyScope.system,
  );

  HotKey get togglePickerHotKey => _togglePickerHotKey;

  Future<void> updateTogglePickerHotKey(HotKey newHotKey) async {
    await hotKeyManager.unregister(_togglePickerHotKey);
    _togglePickerHotKey = newHotKey;
  }

  String getHotKeyDisplayString(HotKey hotKey) {
    final modifiers = hotKey.modifiers?.map((m) {
      switch (m) {
        case KeyModifier.alt:
          return 'Alt';
        case KeyModifier.control:
          return 'Ctrl';
        case KeyModifier.shift:
          return 'Shift';
        case KeyModifier.meta:
          return 'Win';
        default:
          return '';
      }
    }).join(' + ');

    final key = hotKey.keyCode.toString().replaceAll('KeyCode.', '');
    return '${modifiers ?? ''} + ${key.toUpperCase()}';
  }
} 