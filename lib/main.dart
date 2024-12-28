import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'services/color_picker_service.dart';
import 'services/settings_service.dart';
import 'services/theme_service.dart';
import 'pages/settings_page.dart';

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
        return _buildColorPickerView();
      case 1:
        return const Center(child: Text('History View - Coming Soon'));
      case 2:
        return SettingsPage();
      default:
        return _buildColorPickerView();
    }
  }

  Widget _buildColorPickerView() {
    final cmyk = _colorPicker.rgbToCmyk(_selectedColor);
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column - Color Preview
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Status Card
              SizedBox(
                width: 300,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _colorPicker.isActive ? Icons.radio_button_on : Icons.radio_button_off,
                              color: _colorPicker.isActive ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Status: ${_colorPicker.isActive ? "Active" : "Inactive"}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Press ${_settings.getHotKeyDisplayString(_settings.togglePickerHotKey)} to start/stop picking',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          // Right Column - Color Values
          Expanded(
            child: Column(
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
                          value: '#${_selectedColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
                          onCopy: () => _copyToClipboard('#${_selectedColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}'),
                        ),
                        const Divider(),
                        ColorValueTile(
                          label: 'RGB',
                          value: '${_selectedColor.red}, ${_selectedColor.green}, ${_selectedColor.blue}',
                          onCopy: () => _copyToClipboard('${_selectedColor.red}, ${_selectedColor.green}, ${_selectedColor.blue}'),
                        ),
                        const Divider(),
                        ColorValueTile(
                          label: 'CMYK',
                          value: '${cmyk['c']}%, ${cmyk['m']}%, ${cmyk['y']}%, ${cmyk['k']}%',
                          onCopy: () => _copyToClipboard('${cmyk['c']}%, ${cmyk['m']}%, ${cmyk['y']}%, ${cmyk['k']}%'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
