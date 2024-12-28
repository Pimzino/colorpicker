import 'package:flutter/material.dart';
import '../../services/theme_service.dart';
import '../layout/section_layout.dart';

class AppearanceSection extends StatelessWidget {
  final ThemeService _theme = ThemeService();

  AppearanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionLayout(
      title: 'Appearance',
      children: [
        _buildThemeSetting(),
      ],
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
} 