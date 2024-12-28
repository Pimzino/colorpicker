import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../../services/settings_service.dart';
import '../hotkey_recorder.dart';
import '../layout/section_layout.dart';

class HotkeysSection extends StatefulWidget {
  const HotkeysSection({super.key});

  @override
  State<HotkeysSection> createState() => _HotkeysSectionState();
}

class _HotkeysSectionState extends State<HotkeysSection> {
  final SettingsService _settings = SettingsService();
  bool _isRecordingHotkey = false;

  @override
  Widget build(BuildContext context) {
    return SectionLayout(
      title: 'Hotkeys',
      children: [
        _buildHotkeySetting(
          'Toggle Color Picker',
          _settings.getHotKeyDisplayString(_settings.togglePickerHotKey),
          onEdit: () {
            setState(() {
              _isRecordingHotkey = true;
            });
          },
        ),
        if (_isRecordingHotkey) ...[
          const SizedBox(height: 16),
          HotkeyRecorder(
            onHotkeyRecorded: (hotkey) async {
              try {
                await _settings.updateTogglePickerHotKey(hotkey);
                setState(() {
                  _isRecordingHotkey = false;
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Hotkey updated successfully'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to update hotkey'),
                    ),
                  );
                }
              }
            },
            onCancel: () {
              setState(() {
                _isRecordingHotkey = false;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildHotkeySetting(String label, String currentValue, {required VoidCallback onEdit}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.keyboard, size: 20, color: Colors.grey),
                    const SizedBox(width: 12),
                    Text(
                      currentValue,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _isRecordingHotkey ? null : onEdit,
              tooltip: 'Edit hotkey',
            ),
          ],
        ),
      ],
    );
  }
} 