import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsPage extends StatelessWidget {
  final SettingsService _settings = SettingsService();

  SettingsPage({super.key});

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
              // Left column - Hotkeys
              Expanded(
                flex: 3,
                child: Card(
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
                            // TODO: Implement hotkey editing
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Hotkey editing coming soon!'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
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

  Widget _buildHotkeySetting(String label, String currentValue, {required VoidCallback onEdit}) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
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