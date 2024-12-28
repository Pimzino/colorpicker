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

  Function(HotKey)? _hotkeyHandler;

  HotKey get togglePickerHotKey => _togglePickerHotKey;

  Future<void> registerHotkeyHandler(Function(HotKey) handler) async {
    _hotkeyHandler = handler;
    await _registerCurrentHotkey();
  }

  Future<void> _registerCurrentHotkey() async {
    if (_hotkeyHandler != null) {
      try {
        await hotKeyManager.register(
          _togglePickerHotKey,
          keyDownHandler: (_) => _hotkeyHandler!(_togglePickerHotKey),
        );
      } catch (e) {
        debugPrint('Error registering hotkey: $e');
        rethrow;
      }
    }
  }

  Future<void> updateTogglePickerHotKey(HotKey newHotKey) async {
    try {
      // Unregister the old hotkey
      await hotKeyManager.unregister(_togglePickerHotKey);
      
      // Update the hotkey
      _togglePickerHotKey = newHotKey;

      // Register the new hotkey
      await _registerCurrentHotkey();
    } catch (e) {
      debugPrint('Error updating hotkey: $e');
      // If something goes wrong, try to restore the previous hotkey
      if (_togglePickerHotKey != newHotKey) {
        await _registerCurrentHotkey();
      }
      rethrow;
    }
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

    final key = keyCodeToString(hotKey.keyCode);
    return '${modifiers ?? ''} + $key';
  }

  String keyCodeToString(KeyCode keyCode) {
    final keyString = keyCode.toString().toLowerCase();
    
    // Handle letter keys
    if (keyString.startsWith('keycode.key')) {
      return keyString.substring(11).toUpperCase();
    }
    
    // Handle function keys
    if (keyString.startsWith('keycode.f') && keyString.length <= 11) {
      return keyString.substring(8).toUpperCase();
    }
    
    // Handle special keys
    switch (keyCode) {
      case KeyCode.space:
        return 'Space';
      case KeyCode.escape:
        return 'Esc';
      default:
        // For any other keys, just remove the KeyCode. prefix and capitalize
        return keyString.substring(8).toUpperCase();
    }
  }
} 