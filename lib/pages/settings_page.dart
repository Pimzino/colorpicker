import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../services/settings_service.dart';
import '../services/theme_service.dart';
import '../widgets/hotkey_recorder.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsService _settings = SettingsService();
  final ThemeService _theme = ThemeService();
  bool _isRecordingHotkey = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column - Settings
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    // Hotkeys Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hotkeys',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 24),
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
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Appearance Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Appearance',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 24),
                            _buildThemeSetting(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right column - About
              Expanded(
                flex: 2,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Color Picker v1.0.0',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'A modern desktop color picker application for Windows and macOS.',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          '© 2024 Color Picker',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSetting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Theme Mode',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment<ThemeMode>(
              value: ThemeMode.light,
              icon: Icon(Icons.light_mode),
              label: Text('Light'),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.system,
              icon: Icon(Icons.brightness_auto),
              label: Text('System'),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.dark,
              icon: Icon(Icons.dark_mode),
              label: Text('Dark'),
            ),
          ],
          selected: {_theme.themeMode},
          onSelectionChanged: (Set<ThemeMode> selection) {
            _theme.setThemeMode(selection.first);
          },
        ),
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