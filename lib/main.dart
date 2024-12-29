import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/settings_service.dart';
import 'services/color_picker_service.dart';
import 'pages/color_picker_page.dart';
import 'pages/settings_page.dart';
import 'pages/history_page.dart';
import 'dart:developer' as developer;
import 'services/theme_service.dart';
import 'services/update_service.dart';
import 'widgets/splash_screen.dart';

void main() async {
  developer.log('Flutter initialized');
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize hotkey manager
  await hotKeyManager.unregisterAll();  // Clean up any existing hotkeys
  
  developer.log('Window manager initialization started');
  // Initialize window manager
  await windowManager.ensureInitialized();
  
  developer.log('Setting up window properties');
  // Setup window properties
  await windowManager.waitUntilReadyToShow();
  await windowManager.setSize(const Size(900, 750));
  await windowManager.setMinimumSize(const Size(900, 750));
  await windowManager.setMaximumSize(const Size(900, 750));
  await windowManager.center();
  await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  await windowManager.setResizable(false);
  await windowManager.show();
  await windowManager.setSkipTaskbar(false);
  
  developer.log('Running MyApp');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _handleSplashScreen();
  }

  Future<void> _handleSplashScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsService()),
        ChangeNotifierProvider(create: (_) => ColorPickerService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => UpdateService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) => MaterialApp(
          title: 'Color Picker',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
            scrollbarTheme: const ScrollbarThemeData(
              thickness: WidgetStatePropertyAll(0),
              thumbVisibility: WidgetStatePropertyAll(false),
              trackVisibility: WidgetStatePropertyAll(false),
            ),
          ),
          darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            scrollbarTheme: const ScrollbarThemeData(
              thickness: WidgetStatePropertyAll(0),
              thumbVisibility: WidgetStatePropertyAll(false),
              trackVisibility: WidgetStatePropertyAll(false),
            ),
          ),
          themeMode: themeService.themeMode,
          home: _showSplash ? const SplashScreen() : const MyHomePage(),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WindowListener {
  int _selectedIndex = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _initializeApp();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() {
    windowManager.destroy();
  }

  Future<void> _initializeApp() async {
    if (_isInitialized) return;

    try {
      // First unregister any existing hotkeys
      await hotKeyManager.unregisterAll();
      
      if (!mounted) return;
      
      // Then setup our hotkeys
      await _setupHotkeys();
      
      // Start color updates
      _startColorUpdates();
      
      // Check for updates
      if (mounted) {
        final updateService = Provider.of<UpdateService>(context, listen: false);
        updateService.checkForUpdatesIfNeeded(context);
      }
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize app: $e');
      // Show a snackbar to inform the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize hotkeys: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _setupHotkeys() async {
    if (!mounted) return;

    final settings = Provider.of<SettingsService>(context, listen: false);
    final colorPicker = Provider.of<ColorPickerService>(context, listen: false);

    try {
      await settings.registerHotkeyHandler((hotKey) {
        if (!mounted) return;
        if (colorPicker.isActive) {
          colorPicker.stopPicking();
        } else {
          colorPicker.startPicking();
        }
      });
    } catch (e) {
      debugPrint('Failed to setup hotkeys: $e');
      rethrow;
    }
  }

  void _startColorUpdates() {
    Future.delayed(const Duration(milliseconds: 16), () {
      if (mounted) {
        final colorPicker = Provider.of<ColorPickerService>(context, listen: false);
        colorPicker.updateColor();
        _startColorUpdates();
      }
    });
  }

  void _copyToClipboard(String value) {
    // Clear any existing snackbars
    ScaffoldMessenger.of(context).clearSnackBars();
    
    Clipboard.setData(ClipboardData(text: value)).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied to clipboard: $value'),
            behavior: SnackBarBehavior.floating,
            width: 300,
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildTitleBar(),
          Expanded(
            child: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.palette),
                      label: Text('Color Picker'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.history),
                      label: Text('History'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings),
                      label: Text('Settings'),
                    ),
                  ],
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: IconButton(
                          icon: const Icon(Icons.coffee),
                          tooltip: 'Buy Me a Coffee',
                          onPressed: () async {
                            final Uri url = Uri.parse('https://www.buymeacoffee.com/Pimzino');
                            final messenger = ScaffoldMessenger.of(context);
                            if (!await launchUrl(url)) {
                              if (mounted) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Could not open donation link'),
                                    behavior: SnackBarBehavior.floating,
                                    width: 300,
                                    duration: Duration(milliseconds: 1500),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: _buildCurrentView(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleBar() {
    return Column(
      children: [
        GestureDetector(
          onPanStart: (details) {
            windowManager.startDragging();
          },
          child: Container(
            height: 32,
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Icon(Icons.palette, size: 16),
                const SizedBox(width: 8),
                const Text('Color Picker'),
                const Spacer(),
                _WindowButton(
                  icon: Icons.minimize,
                  onPressed: () async {
                    await windowManager.minimize();
                  },
                ),
                _WindowButton(
                  icon: Icons.close,
                  onPressed: () async {
                    await windowManager.close();
                  },
                  isClose: true,
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1),
      ],
    );
  }

  Widget _buildCurrentView() {
    final colorPicker = Provider.of<ColorPickerService>(context);
    final settings = Provider.of<SettingsService>(context);

    switch (_selectedIndex) {
      case 0:
        return ColorPickerPage(
          selectedColor: colorPicker.currentColor,
          colorPicker: colorPicker,
          settings: settings,
          onCopy: _copyToClipboard,
        );
      case 1:
        return HistoryPage(onCopy: _copyToClipboard);
      case 2:
        return const SettingsPage();
      default:
        return const SizedBox.shrink();
    }
  }
}

class _WindowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isClose;

  const _WindowButton({
    required this.icon,
    required this.onPressed,
    this.isClose = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      style: IconButton.styleFrom(
        minimumSize: const Size(46, 32),
        shape: const RoundedRectangleBorder(),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        hoverColor: isClose 
          ? Theme.of(context).colorScheme.error.withAlpha(25)
          : Theme.of(context).colorScheme.onSurface.withAlpha(25),
      ),
    );
  }
}
