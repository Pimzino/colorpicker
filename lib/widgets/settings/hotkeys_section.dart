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
        padding: const EdgeInsets.all(16.0),
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
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Toggle Color Picker'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(128),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.keyboard, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    settings.getHotKeyDisplayString(settings.togglePickerHotKey),
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                settings.startRecordingHotkey();
                              },
                              tooltip: 'Edit hotkey',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
} 