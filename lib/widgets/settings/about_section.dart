import 'package:flutter/material.dart';
import '../../services/update_service.dart';

class AboutSection extends StatefulWidget {
  const AboutSection({super.key});

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> {
  bool _isCheckingUpdate = false;

  Future<void> _checkForUpdates() async {
    setState(() {
      _isCheckingUpdate = true;
    });

    try {
      final (hasUpdate, latestVersion, downloadUrl) = await UpdateService.checkForUpdates();
      
      if (mounted) {
        setState(() {
          _isCheckingUpdate = false;
        });

        if (hasUpdate) {
          await UpdateService.showUpdateDialog(context, latestVersion, downloadUrl);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are using the latest version'),
              behavior: SnackBarBehavior.floating,
              width: 300,
              duration: Duration(milliseconds: 1500),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingUpdate = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to check for updates'),
            behavior: SnackBarBehavior.floating,
            width: 300,
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Version',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      UpdateService.appVersion,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                FilledButton.tonalIcon(
                  onPressed: _isCheckingUpdate ? null : _checkForUpdates,
                  icon: _isCheckingUpdate 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.update),
                  label: Text(_isCheckingUpdate ? 'Checking...' : 'Check for Updates'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'A modern desktop color picker application for Windows and macOS.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              '© 2024 Color Picker',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
} 