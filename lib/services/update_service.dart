import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class UpdateService extends ChangeNotifier {
  static const String _owner = 'Pimzino';
  static const String _repo = 'ColorPicker';
  static const String _apiUrl = 'https://api.github.com/repos/$_owner/$_repo/releases/latest';
  static const String appVersion = '1.0.0';

  bool _hasCheckedForUpdates = false;

  void checkForUpdatesIfNeeded(BuildContext context) {
    if (_hasCheckedForUpdates) return;
    _hasCheckedForUpdates = true;

    // Fire and forget - completely async
    _checkForUpdates(context);
  }

  Future<void> _checkForUpdates(BuildContext context) async {
    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {'User-Agent': 'ColorPicker-App'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = (data['tag_name'] as String).replaceAll('v', '');
        final downloadUrl = data['html_url'] as String;

        final hasUpdate = _compareVersions(appVersion, latestVersion);
        if (hasUpdate && context.mounted) {
          await showUpdateDialog(context, latestVersion, downloadUrl);
        }
      }
    } catch (e) {
      debugPrint('Failed to check for updates: $e');
      // Silently fail on startup check
    }
  }

  // For manual update checks from the About section
  static Future<(bool, String, String)> checkForUpdates() async {
    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {'User-Agent': 'ColorPicker-App'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = (data['tag_name'] as String).replaceAll('v', '');
        final downloadUrl = data['html_url'] as String;

        // Compare versions
        final hasUpdate = _compareVersions(appVersion, latestVersion);
        return (hasUpdate, latestVersion, downloadUrl);
      } else if (response.statusCode == 404) {
        throw 'No releases found. Please check back later.';
      } else {
        throw 'Failed to check for updates (Status ${response.statusCode})';
      }
    } on SocketException {
      throw 'No internet connection available';
    } on FormatException {
      throw 'Invalid response from update server';
    } catch (e) {
      if (e is String) rethrow;
      throw 'Unexpected error while checking for updates';
    }
  }

  static bool _compareVersions(String current, String latest) {
    try {
      final currentParts = current.split('.').map(int.parse).toList();
      final latestParts = latest.split('.').map(int.parse).toList();

      for (var i = 0; i < 3; i++) {
        final currentPart = currentParts[i];
        final latestPart = latestParts[i];
        if (latestPart > currentPart) return true;
        if (latestPart < currentPart) return false;
      }
      return false;
    } catch (e) {
      debugPrint('Failed to compare versions: $e');
      return false;
    }
  }

  static Future<void> showUpdateDialog(BuildContext context, String newVersion, String downloadUrl) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Available'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('A new version ($newVersion) is available.'),
            const SizedBox(height: 8),
            Text(
              'Current version: $appVersion',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () async {
              final url = Uri.parse(downloadUrl);
              try {
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              } catch (e) {
                debugPrint('Failed to launch URL: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to open download page'),
                      behavior: SnackBarBehavior.floating,
                      width: 300,
                      duration: Duration(milliseconds: 1500),
                    ),
                  );
                }
              }
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }
} 