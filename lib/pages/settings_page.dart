import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/theme_service.dart';
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
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Settings',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          FilledButton.tonalIcon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Reset Settings'),
                                  content: const Text('Are you sure you want to reset all settings to default?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () {
                                        final settings = Provider.of<SettingsService>(context, listen: false);
                                        final themeService = Provider.of<ThemeService>(context, listen: false);
                                        settings.resetToDefaults();
                                        themeService.resetToDefaults();
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Settings reset to default'),
                                            behavior: SnackBarBehavior.floating,
                                            width: 300,
                                            duration: Duration(milliseconds: 1500),
                                          ),
                                        );
                                      },
                                      child: const Text('Reset'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.restore),
                            label: const Text('Reset to Default'),
                          ),
                        ],
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
        ),
      ],
    );
  }
} 