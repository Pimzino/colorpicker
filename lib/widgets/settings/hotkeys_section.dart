import 'package:flutter/material.dart';
import '../../services/settings_service.dart';
import '../hotkey_recorder.dart';
import 'package:provider/provider.dart';

class HotkeysSection extends StatelessWidget {
  const HotkeysSection({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hotkeys',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (settings.isRecordingHotkey)
              HotkeyRecorder(
                onHotkeyRecorded: (hotkey) async {
                  await settings.updateTogglePickerHotKey(hotkey);
                },
                onCancel: () => settings.stopRecordingHotkey(),
              )
            else
              _buildHotkeyRow(
                context,
                'Toggle Color Picker',
                settings.getHotKeyDisplayString(settings.togglePickerHotKey),
                () => settings.startRecordingHotkey(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotkeyRow(BuildContext context, String label, String hotkey, VoidCallback onEdit) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.keyboard, size: 20),
                    const SizedBox(width: 8),
                    Text(hotkey),
                  ],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: onEdit,
          tooltip: 'Edit hotkey',
        ),
      ],
    );
  }
} 