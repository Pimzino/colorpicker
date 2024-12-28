import 'package:flutter/material.dart';
import '../services/color_picker_service.dart';
import '../services/settings_service.dart';

class ColorPickerPage extends StatelessWidget {
  final Color selectedColor;
  final ColorPickerService colorPicker;
  final SettingsService settings;
  final Function(String) onCopy;

  const ColorPickerPage({
    super.key,
    required this.selectedColor,
    required this.colorPicker,
    required this.settings,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                // Color Preview - Centered at the top
                Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Color Values - Below the preview
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Color Values',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _buildColorValue('HEX', '#${selectedColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}'),
                        const Divider(),
                        _buildColorValue('RGB', '${selectedColor.red}, ${selectedColor.green}, ${selectedColor.blue}'),
                        const Divider(),
                        _buildColorValue(
                          'CMYK',
                          _getCMYKString(colorPicker.rgbToCmyk(selectedColor)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        // Status info at the bottom
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    colorPicker.isActive ? Icons.radio_button_on : Icons.radio_button_off,
                    color: colorPicker.isActive ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Status: ${colorPicker.isActive ? "Active" : "Inactive"}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Press ${settings.getHotKeyDisplayString(settings.togglePickerHotKey)} to start/stop picking',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 20),
            onPressed: () => onCopy(value),
            tooltip: 'Copy to clipboard',
          ),
        ],
      ),
    );
  }

  String _getCMYKString(Map<String, double> cmyk) {
    return '${cmyk['c']}%, ${cmyk['m']}%, ${cmyk['y']}%, ${cmyk['k']}%';
  }
} 