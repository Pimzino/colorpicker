import 'package:flutter/material.dart';
import '../widgets/settings/hotkeys_section.dart';
import '../widgets/settings/appearance_section.dart';
import '../widgets/settings/about_section.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    const HotkeysSection(),
                    const SizedBox(height: 24),
                    const AppearanceSection(),
                    const SizedBox(height: 24),
                    const AboutSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
} 