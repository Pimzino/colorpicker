# Color Picker

<div align="center">

![Color Picker Logo](assets/images/logo.png)

A modern, sleek desktop color picker application for Windows and macOS.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-donate-yellow.svg)](https://www.buymeacoffee.com/pimzino)

</div>

## Features

🎨 **Real-time Color Picking**
- Hover over any pixel on your screen to get its color
- Global hotkey support for quick color picking
- Shows color preview in real-time

🎯 **Multiple Color Formats**
- HEX color codes
- RGB values
- CMYK values

📚 **Color History**
- Automatically saves picked colors
- Easy access to previously picked colors
- Copy color values with a single click

⚙️ **Customization**
- Configurable hotkeys
- Light/Dark theme support
- Customizable UI preferences

🔄 **Auto Updates**
- Automatic update checks
- Easy one-click updates
- Silent installation process

## Screenshots

[Screenshots of the application in action]

## Installation

### Windows
1. Download the latest installer from the [Releases](https://github.com/Pimzino/ColorPicker/releases) page
2. Run the installer
3. Launch Color Picker from the Start Menu

### macOS
1. Download the latest package from the [Releases](https://github.com/Pimzino/ColorPicker/releases) page
2. Open the package
3. Drag Color Picker to your Applications folder

## Building from Source

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Git
- Windows:
  - Visual Studio 2019 or later with C++ development tools
  - Windows 10 SDK
- macOS:
  - Xcode
  - CocoaPods

### Windows Build
```bash
# Clone the repository
git clone https://github.com/Pimzino/ColorPicker.git
cd ColorPicker

# Get dependencies
flutter pub get

# Build Windows release
flutter build windows --release
```

### macOS Build
```bash
# Clone the repository
git clone https://github.com/Pimzino/ColorPicker.git
cd ColorPicker

# Get dependencies
flutter pub get

# Build macOS release
flutter build macos --release
```

## Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **Platform APIs**:
  - Windows: Win32 API
  - macOS: Cocoa API (coming soon)
- **Key Packages**:
  - `hotkey_manager`: Global hotkey support
  - `window_manager`: Window management
  - `provider`: State management
  - `shared_preferences`: Settings storage
  - `win32`: Windows API integration

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Support

If you find this project helpful, consider buying me a coffee:

<a href="https://www.buymeacoffee.com/pimzino" target="_blank">
  <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="60">
</a>

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Credits

- **Developer**: [Pimzino](https://github.com/Pimzino)
- **Contributors**: [List of contributors]
- **Icons**: [Icon credits if applicable]

## Acknowledgments

- Thanks to the Flutter team for the amazing framework
- All the contributors who have helped with the project
- The open-source community for their invaluable tools and libraries
