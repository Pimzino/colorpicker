import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'storage_service.dart';

class SettingsService extends ChangeNotifier {
  HotKey _togglePickerHotKey;
  bool _isRecordingHotkey = false;
  Function(HotKey)? _currentHandler;
  bool _hotkeyRegistered = false;

  SettingsService() : _togglePickerHotKey = StorageService.loadHotkey();

  HotKey get togglePickerHotKey => _togglePickerHotKey;
  bool get isRecordingHotkey => _isRecordingHotkey;

  void startRecordingHotkey() async {
    try {
      // Unregister current hotkey before recording
      if (_hotkeyRegistered) {
        await hotKeyManager.unregister(_togglePickerHotKey);
        _hotkeyRegistered = false;
      }
      _isRecordingHotkey = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to start recording hotkey: $e');
    }
  }

  void stopRecordingHotkey() {
    _isRecordingHotkey = false;
    notifyListeners();
  }

  Future<void> updateTogglePickerHotKey(HotKey hotkey) async {
    try {
      // Always try to unregister the old hotkey first
      if (_hotkeyRegistered) {
        try {
          await hotKeyManager.unregister(_togglePickerHotKey);
        } catch (e) {
          debugPrint('Failed to unregister old hotkey: $e');
          // Continue anyway as we want to update the hotkey
        }
      }
      
      _hotkeyRegistered = false;
      
      // Update to the new hotkey
      _togglePickerHotKey = hotkey;
      await StorageService.saveHotkey(hotkey);
      
      // Re-register with the current handler if one exists
      if (_currentHandler != null) {
        await registerHotkeyHandler(_currentHandler!);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to update hotkey: $e');
      rethrow;
    } finally {
      stopRecordingHotkey();
    }
  }

  String getHotKeyDisplayString(HotKey hotkey) {
    final List<String> parts = [];
    
    if (hotkey.modifiers?.contains(KeyModifier.control) ?? false) {
      parts.add('Ctrl');
    }
    if (hotkey.modifiers?.contains(KeyModifier.shift) ?? false) {
      parts.add('Shift');
    }
    if (hotkey.modifiers?.contains(KeyModifier.alt) ?? false) {
      parts.add('Alt');
    }
    
    String keyName = keyCodeToString(hotkey.keyCode);
    parts.add(keyName);
    
    return parts.join(' + ');
  }

  String keyCodeToString(KeyCode keyCode) {
    final keyString = keyCode.toString().replaceAll('KeyCode.', '');
    
    // Handle letter keys
    if (keyString.startsWith('key')) {
      return keyString.substring(3).toUpperCase();
    }

    // Handle function keys
    if (keyString.startsWith('f') && keyString.length <= 3) {
      return keyString.toUpperCase();
    }
    
    // Handle special keys
    switch (keyCode) {
      case KeyCode.space:
        return 'Space';
      case KeyCode.escape:
        return 'Esc';
      case KeyCode.enter:
        return 'Enter';
      case KeyCode.tab:
        return 'Tab';
      case KeyCode.capsLock:
        return 'Caps Lock';
      case KeyCode.delete:
        return 'Delete';
      case KeyCode.end:
        return 'End';
      case KeyCode.home:
        return 'Home';
      case KeyCode.pageDown:
        return 'Page Down';
      case KeyCode.pageUp:
        return 'Page Up';
      case KeyCode.arrowDown:
        return '↓';
      case KeyCode.arrowLeft:
        return '←';
      case KeyCode.arrowRight:
        return '→';
      case KeyCode.arrowUp:
        return '↑';
      default:
        // Capitalize first letter and format remaining text
        return keyString.substring(0, 1).toUpperCase() + 
               keyString.substring(1).replaceAllMapped(
                 RegExp(r'[A-Z]'),
                 (match) => ' ${match.group(0)}'
               );
    }
  }

  Future<void> registerHotkeyHandler(Function(HotKey) handler) async {
    try {
      _currentHandler = handler;
      
      // Unregister any existing hotkey first
      if (_hotkeyRegistered) {
        try {
          await hotKeyManager.unregister(_togglePickerHotKey);
        } catch (e) {
          debugPrint('Failed to unregister existing hotkey: $e');
          // Continue anyway as we want to register the new handler
        }
      }
      
      _hotkeyRegistered = false;

      // Register the new hotkey
      await hotKeyManager.register(
        _togglePickerHotKey,
        keyDownHandler: (_) {
          try {
            handler(_togglePickerHotKey);
          } catch (e) {
            debugPrint('Error in hotkey handler: $e');
          }
        },
      );
      
      _hotkeyRegistered = true;
      debugPrint('Successfully registered hotkey: ${getHotKeyDisplayString(_togglePickerHotKey)}');
    } catch (e) {
      debugPrint('Failed to register hotkey handler: $e');
      _hotkeyRegistered = false;
      rethrow;
    }
  }
} 