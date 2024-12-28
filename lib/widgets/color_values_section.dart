import 'package:flutter/material.dart';
import '../services/color_picker_service.dart';

class ColorValuesSection extends StatelessWidget {
  final Color selectedColor;
  final ColorPickerService colorPicker;
  final Function(String) onCopy;

  const ColorValuesSection({
    super.key,
    required this.selectedColor,
    required this.colorPicker,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final cmyk = colorPicker.rgbToCmyk(selectedColor);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color Values:',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ColorValueTile(
                  label: 'HEX',
                  value: '#${selectedColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
                  onCopy: () => onCopy('#${selectedColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}'),
                ),
                const Divider(),
                ColorValueTile(
                  label: 'RGB',
                  value: '${selectedColor.red}, ${selectedColor.green}, ${selectedColor.blue}',
                  onCopy: () => onCopy('${selectedColor.red}, ${selectedColor.green}, ${selectedColor.blue}'),
                ),
                const Divider(),
                ColorValueTile(
                  label: 'CMYK',
                  value: '${cmyk['c']}%, ${cmyk['m']}%, ${cmyk['y']}%, ${cmyk['k']}%',
                  onCopy: () => onCopy('${cmyk['c']}%, ${cmyk['m']}%, ${cmyk['y']}%, ${cmyk['k']}%'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ColorValueTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onCopy;

  const ColorValueTile({
    super.key,
    required this.label,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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
            onPressed: onCopy,
            tooltip: 'Copy to clipboard',
          ),
        ],
      ),
    );
  }
} 