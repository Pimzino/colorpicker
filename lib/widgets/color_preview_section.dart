import 'package:flutter/material.dart';
import '../services/color_picker_service.dart';
import '../services/settings_service.dart';

class ColorPreviewSection extends StatelessWidget {
  final Color selectedColor;
  final ColorPickerService colorPicker;
  final SettingsService settings;

  const ColorPreviewSection({
    super.key,
    required this.selectedColor,
    required this.colorPicker,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            color: selectedColor,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 300,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        colorPicker.isActive ? Icons.radio_button_on : Icons.radio_button_off,
                        color: colorPicker.isActive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Status: ${colorPicker.isActive ? "Active" : "Inactive"}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Press ${settings.getHotKeyDisplayString(settings.togglePickerHotKey)} to start/stop picking',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
} 