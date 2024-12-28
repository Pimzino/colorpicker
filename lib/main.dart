import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'services/color_picker_service.dart';
import 'services/settings_service.dart';
import 'services/theme_service.dart';
import 'pages/settings_page.dart';
import 'pages/color_picker_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize window manager
  await windowManager.ensureInitialized();
  // Initialize hotkey manager
  await hotKeyManager.unregisterAll();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(900, 700),
    minimumSize: Size(900, 700),
    maximumSize: Size(900, 700),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'Color Picker',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setPreventClose(true);
    await windowManager.setResizable(false);
  });

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeService _theme = ThemeService();

  @override
  void initState() {
    super.initState();
    _theme.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _theme.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Picker',
      theme: _theme.getLightTheme(),
      darkTheme: _theme.getDarkTheme(),
      themeMode: _theme.themeMode,
      home: const ColorPickerHome(),
    );
  }
}

class ColorPickerHome extends StatefulWidget {
  const ColorPickerHome({super.key});

  @override
  State<ColorPickerHome> createState() => _ColorPickerHomeState();
}

class _ColorPickerHomeState extends State<ColorPickerHome> {
  final ColorPickerService _colorPicker = ColorPickerService();
  final SettingsService _settings = SettingsService();
  Color _selectedColor = Colors.white;
  int _selectedIndex = 0;

  final List<NavigationRailDestination> _destinations = const [
    NavigationRailDestination(
      icon: Icon(Icons.colorize),
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
  ];

  @override
  void initState() {
    super.initState();
    _setupHotkeys();
    _colorPicker.addListener(_onColorChanged);
  }

  @override
  void dispose() {
    _colorPicker.removeListener(_onColorChanged);
    hotKeyManager.unregisterAll();
    super.dispose();
  }

  void _onColorChanged(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  Future<void> _setupHotkeys() async {
    await _settings.registerHotkeyHandler((hotkey) {
      setState(() {
        if (_colorPicker.isActive) {
          _colorPicker.stopPicking();
        } else {
          _colorPicker.startPicking();
        }
      });
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard'),
          duration: Duration(seconds: 1),
        ),
      );
    });
  }

  Widget _buildCurrentView() {
    switch (_selectedIndex) {
      case 0:
        return ColorPickerPage(
          selectedColor: _selectedColor,
          colorPicker: _colorPicker,
          settings: _settings,
          onCopy: _copyToClipboard,
        );
      case 1:
        return const Center(child: Text('History View - Coming Soon'));
      case 2:
        return const SettingsPage();
      default:
        return ColorPickerPage(
          selectedColor: _selectedColor,
          colorPicker: _colorPicker,
          settings: _settings,
          onCopy: _copyToClipboard,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: _destinations,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _buildCurrentView(),
          ),
        ],
      ),
    );
  }
}
