import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../services/settings_service.dart';

class HotkeyRecorder extends StatefulWidget {
  final Function(HotKey) onHotkeyRecorded;
  final VoidCallback onCancel;

  const HotkeyRecorder({
    super.key,
    required this.onHotkeyRecorded,
    required this.onCancel,
  });

  @override
  State<HotkeyRecorder> createState() => _HotkeyRecorderState();
}

class _HotkeyRecorderState extends State<HotkeyRecorder> {
  final Set<KeyModifier> _activeModifiers = {};
  KeyCode? _activeKey;
  final SettingsService _settings = SettingsService();

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKey: _handleKeyEvent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.keyboard, size: 20, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getDisplayText(),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: widget.onCancel,
              tooltip: 'Cancel',
            ),
          ],
        ),
      ),
    );
  }

  String _getDisplayText() {
    if (_activeModifiers.isEmpty && _activeKey == null) {
      return 'Press keys to record hotkey...';
    }

    final modifiers = _activeModifiers.map((m) {
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

    final key = _activeKey != null ? _settings.keyCodeToString(_activeKey!) : '';
    
    if (modifiers.isEmpty) {
      return key;
    }
    
    return key.isEmpty ? modifiers : '$modifiers + $key';
  }

  KeyCode? _mapLogicalKeyToKeyCode(LogicalKeyboardKey key) {
    // Map for special keys
    final specialKeys = {
      LogicalKeyboardKey.escape: KeyCode.escape,
      LogicalKeyboardKey.f1: KeyCode.f1,
      LogicalKeyboardKey.f2: KeyCode.f2,
      LogicalKeyboardKey.f3: KeyCode.f3,
      LogicalKeyboardKey.f4: KeyCode.f4,
      LogicalKeyboardKey.f5: KeyCode.f5,
      LogicalKeyboardKey.f6: KeyCode.f6,
      LogicalKeyboardKey.f7: KeyCode.f7,
      LogicalKeyboardKey.f8: KeyCode.f8,
      LogicalKeyboardKey.f9: KeyCode.f9,
      LogicalKeyboardKey.f10: KeyCode.f10,
      LogicalKeyboardKey.f11: KeyCode.f11,
      LogicalKeyboardKey.f12: KeyCode.f12,
      LogicalKeyboardKey.space: KeyCode.space,
    };

    // Check special keys first
    if (specialKeys.containsKey(key)) {
      return specialKeys[key];
    }

    // Handle letter keys
    final keyLabel = key.keyLabel.toLowerCase();
    if (keyLabel.length == 1 && keyLabel.contains(RegExp(r'[a-z]'))) {
      try {
        return KeyCode.values.firstWhere(
          (k) => k.toString().toLowerCase() == 'keycode.key$keyLabel',
        );
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      // Handle modifiers
      if (event.isAltPressed) {
        _activeModifiers.add(KeyModifier.alt);
      }
      if (event.isControlPressed) {
        _activeModifiers.add(KeyModifier.control);
      }
      if (event.isShiftPressed) {
        _activeModifiers.add(KeyModifier.shift);
      }
      if (event.isMetaPressed) {
        _activeModifiers.add(KeyModifier.meta);
      }

      // Handle regular keys
      final keyCode = _mapLogicalKeyToKeyCode(event.logicalKey);
      if (keyCode != null) {
        _activeKey = keyCode;
        if (_activeModifiers.isNotEmpty) {
          widget.onHotkeyRecorded(
            HotKey(
              keyCode,
              modifiers: _activeModifiers.toList(),
              scope: HotKeyScope.system,
            ),
          );
        }
      }

      setState(() {});
    } else if (event is RawKeyUpEvent) {
      // Clear modifiers when released
      if (!event.isAltPressed) {
        _activeModifiers.remove(KeyModifier.alt);
      }
      if (!event.isControlPressed) {
        _activeModifiers.remove(KeyModifier.control);
      }
      if (!event.isShiftPressed) {
        _activeModifiers.remove(KeyModifier.shift);
      }
      if (!event.isMetaPressed) {
        _activeModifiers.remove(KeyModifier.meta);
      }

      setState(() {});
    }
  }
} 