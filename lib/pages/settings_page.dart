import 'package:flutter/material.dart';
import '../widgets/settings/hotkeys_section.dart';
import '../widgets/settings/appearance_section.dart';
import '../widgets/settings/about_section.dart';
import '../widgets/layout/page_layout.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: 'Settings',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column - Settings
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  const HotkeysSection(),
                  const SizedBox(height: 24),
                  AppearanceSection(),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Right column - About
            const Expanded(
              flex: 2,
              child: AboutSection(),
            ),
          ],
        ),
      ],
    );
  }
} 