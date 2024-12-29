import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class UpdateService extends ChangeNotifier {
  static const String _owner = 'Pimzino';
  static const String _repo = 'ColorPicker';
  static const String _apiUrl = 'https://api.github.com/repos/$_owner/$_repo/releases/latest';
  static const String appVersion = '1.0.0';

  bool _hasCheckedForUpdates = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

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
        
        // Get the installer asset URL
        final assets = data['assets'] as List;
        final installerAsset = assets.firstWhere(
          (asset) => asset['name'].toString().toLowerCase().endsWith('.exe'),
          orElse: () => null,
        );

        if (installerAsset == null) {
          debugPrint('No installer found in release');
          return;
        }

        final downloadUrl = installerAsset['browser_download_url'] as String;
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
        
        // Get the installer asset URL
        final assets = data['assets'] as List;
        final installerAsset = assets.firstWhere(
          (asset) => asset['name'].toString().toLowerCase().endsWith('.exe'),
          orElse: () => null,
        );

        if (installerAsset == null) {
          throw 'No installer found in release';
        }

        final downloadUrl = installerAsset['browser_download_url'] as String;
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

  Future<void> _downloadAndInstallUpdate(String downloadUrl, BuildContext context) async {
    try {
      _isDownloading = true;
      _downloadProgress = 0.0;
      notifyListeners();

      // Get temp directory for downloading the installer
      final tempDir = await getTemporaryDirectory();
      final installerPath = '${tempDir.path}\\ColorPicker_Setup.exe';

      // Download the file
      final response = await http.Client().send(
        http.Request('GET', Uri.parse(downloadUrl))..headers['User-Agent'] = 'ColorPicker-App',
      );

      final totalBytes = response.contentLength ?? 0;
      var receivedBytes = 0;

      final file = File(installerPath);
      final sink = file.openWrite();

      await response.stream.listen(
        (chunk) {
          sink.add(chunk);
          receivedBytes += chunk.length;
          _downloadProgress = totalBytes > 0 ? receivedBytes / totalBytes : 0;
          notifyListeners();
        },
        onDone: () async {
          await sink.close();
          _isDownloading = false;
          notifyListeners();

          // Run the installer with silent update parameters
          // /SILENT runs the installer silently but shows progress
          // /CLOSEAPPLICATIONS closes the current app instance
          // /RESTARTAPPLICATIONS restarts the app after update
          await Process.start(
            installerPath,
            ['/SILENT', '/CLOSEAPPLICATIONS', '/RESTARTAPPLICATIONS'],
            mode: ProcessStartMode.detached,
          );

          // Exit the current app instance to allow the installer to proceed
          exit(0);
        },
      ).asFuture();
    } catch (e) {
      _isDownloading = false;
      _downloadProgress = 0.0;
      notifyListeners();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to download update'),
            behavior: SnackBarBehavior.floating,
            width: 300,
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
      debugPrint('Failed to download and install update: $e');
    }
  }

  static Future<void> showUpdateDialog(BuildContext context, String newVersion, String downloadUrl) async {
    final updateService = UpdateService();
    
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Update Available'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('A new version ($newVersion) is available.'),
              const SizedBox(height: 8),
              Text(
                'Current version: $appVersion',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (updateService._isDownloading) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: updateService._downloadProgress,
                ),
                const SizedBox(height: 8),
                Text(
                  'Downloading update... ${(updateService._downloadProgress * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: updateService._isDownloading 
              ? null 
              : () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: updateService._isDownloading 
              ? null 
              : () => updateService._downloadAndInstallUpdate(downloadUrl, context),
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }
} 