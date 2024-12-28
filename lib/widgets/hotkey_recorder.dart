import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../services/settings_service.dart';
import 'package:provider/provider.dart';

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
  Set<LogicalKeyboardKey> _recordedKeys = {};
  bool _isRecording = true;
  final FocusNode _focusNode = FocusNode();
  String? _errorMessage;

  bool get _isValidCombination {
    if (_recordedKeys.isEmpty) return false;
    
    bool hasNonModifier = _recordedKeys.any((key) => !_isModifierKey(key));
    return hasNonModifier;
  }

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (_, event) {
        _handleKeyEvent(event);
        return KeyEventResult.handled;
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withAlpha(100),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.keyboard,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Record Hotkey',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Press the keys you want to use as your hotkey.\nYou can use any combination of modifier keys (Ctrl, Shift, Alt)\nwith one other key.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _errorMessage != null 
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getDisplayText(),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: _recordedKeys.isEmpty
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (_recordedKeys.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Reset',
                          onPressed: _resetHotkey,
                          visualDensity: VisualDensity.compact,
                          style: IconButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _isValidCombination ? _saveHotkey : null,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDisplayText() {
    if (_recordedKeys.isEmpty) {
      return 'Press your desired key combination...';
    }

    final modifiers = <KeyModifier>[];
    final nonModifierKeys = <KeyCode>[];

    try {
      for (final key in _recordedKeys) {
        if (_isModifierKey(key)) {
          final modifier = _convertToKeyModifier(key);
          if (!modifiers.contains(modifier)) {
            modifiers.add(modifier);
          }
        } else {
          final keyCode = _logicalKeyToKeyCode(key);
          if (!nonModifierKeys.contains(keyCode)) {
            nonModifierKeys.add(keyCode);
          }
        }
      }

      if (nonModifierKeys.isEmpty && modifiers.isNotEmpty) {
        _errorMessage = 'Add at least one non-modifier key';
        return 'Invalid: Only modifier keys';
      }

      _errorMessage = null;
      if (nonModifierKeys.isEmpty) {
        return 'Invalid hotkey combination';
      }

      // Create a display string for all keys
      final nonModifierDisplay = nonModifierKeys.map((k) => _keyCodeToDisplayString(k)).join(' + ');
      final modifierDisplay = modifiers.isEmpty ? '' : '${modifiers.map((m) => _modifierToDisplayString(m)).join(' + ')} + ';
      return '$modifierDisplay$nonModifierDisplay';
    } catch (e) {
      _errorMessage = 'Invalid key combination';
      return 'Invalid key combination';
    }
  }

  String _keyCodeToDisplayString(KeyCode keyCode) {
    final keyString = keyCode.toString().replaceAll('KeyCode.', '');
    if (keyString.startsWith('key')) {
      return keyString.substring(3).toUpperCase();
    }
    return keyString.substring(0, 1).toUpperCase() + keyString.substring(1);
  }

  String _modifierToDisplayString(KeyModifier modifier) {
    switch (modifier) {
      case KeyModifier.control:
        return 'Ctrl';
      case KeyModifier.shift:
        return 'Shift';
      case KeyModifier.alt:
        return 'Alt';
      case KeyModifier.meta:
        return 'Win';
      default:
        return modifier.toString().split('.').last;
    }
  }

  KeyModifier _convertToKeyModifier(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.control ||
        key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight) {
      return KeyModifier.control;
    } else if (key == LogicalKeyboardKey.shift ||
               key == LogicalKeyboardKey.shiftLeft ||
               key == LogicalKeyboardKey.shiftRight) {
      return KeyModifier.shift;
    } else if (key == LogicalKeyboardKey.alt ||
               key == LogicalKeyboardKey.altLeft ||
               key == LogicalKeyboardKey.altRight) {
      return KeyModifier.alt;
    } else if (key == LogicalKeyboardKey.meta ||
               key == LogicalKeyboardKey.metaLeft ||
               key == LogicalKeyboardKey.metaRight) {
      return KeyModifier.meta;
    }
    throw Exception('Unknown modifier key');
  }

  void _handleKeyEvent(KeyEvent event) {
    if (!_isRecording) return;

    if (event is KeyDownEvent) {
      setState(() {
        // If it's a non-modifier key, clear any existing non-modifier keys
        if (!_isModifierKey(event.logicalKey)) {
          _recordedKeys.removeWhere((key) => !_isModifierKey(key));
        }
        _recordedKeys.add(event.logicalKey);
        _errorMessage = null;
      });
    }
  }

  void _resetHotkey() {
    setState(() {
      _recordedKeys.clear();
      _errorMessage = null;
    });
    _focusNode.requestFocus();
  }

  void _saveHotkey() {
    if (_recordedKeys.isEmpty) return;

    final modifiers = <KeyModifier>[];
    final nonModifierKeys = <KeyCode>[];

    for (final key in _recordedKeys) {
      if (_isModifierKey(key)) {
        final modifier = _convertToKeyModifier(key);
        if (!modifiers.contains(modifier)) {
          modifiers.add(modifier);
        }
      } else {
        final keyCode = _logicalKeyToKeyCode(key);
        if (!nonModifierKeys.contains(keyCode)) {
          nonModifierKeys.add(keyCode);
        }
      }
    }

    if (nonModifierKeys.isNotEmpty) {
      setState(() => _isRecording = false);
      widget.onHotkeyRecorded(HotKey(nonModifierKeys.first, modifiers: modifiers));
    }
  }

  bool _isModifierKey(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.control ||
           key == LogicalKeyboardKey.controlLeft ||
           key == LogicalKeyboardKey.controlRight ||
           key == LogicalKeyboardKey.shift ||
           key == LogicalKeyboardKey.shiftLeft ||
           key == LogicalKeyboardKey.shiftRight ||
           key == LogicalKeyboardKey.alt ||
           key == LogicalKeyboardKey.altLeft ||
           key == LogicalKeyboardKey.altRight;
  }

  KeyCode _logicalKeyToKeyCode(LogicalKeyboardKey key) {
    // Map common keys
    final keyLabel = key.keyLabel.toLowerCase();
    if (keyLabel.length == 1 && keyLabel.contains(RegExp(r'[a-z]'))) {
      return KeyCode.values.firstWhere(
        (k) => k.toString().toLowerCase() == 'keycode.key$keyLabel',
        orElse: () => throw Exception('Unsupported key'),
      );
    }

    // Map function keys
    if (key.keyLabel.toLowerCase().startsWith('f') && 
        key.keyLabel.substring(1).contains(RegExp(r'^\d+$'))) {
      return KeyCode.values.firstWhere(
        (k) => k.toString().toLowerCase() == 'keycode.${key.keyLabel.toLowerCase()}',
        orElse: () => throw Exception('Unsupported key'),
      );
    }

    // Map special keys
    switch (key) {
      case LogicalKeyboardKey.space:
        return KeyCode.space;
      case LogicalKeyboardKey.enter:
        return KeyCode.enter;
      case LogicalKeyboardKey.tab:
        return KeyCode.tab;
      case LogicalKeyboardKey.escape:
        return KeyCode.escape;
      default:
        throw Exception('Unsupported key');
    }
  }
} 