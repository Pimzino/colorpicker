import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:win32/win32.dart';
import 'storage_service.dart';

class ColorPickerService extends ChangeNotifier {
  bool _isPicking = false;
  Color _currentColor = Colors.white;
  static const int clrInvalid = 0xFFFFFFFF;

  bool get isActive => _isPicking;
  Color get currentColor => _currentColor;

  void startPicking() {
    _isPicking = true;
    notifyListeners();
  }

  Future<void> stopPicking() async {
    if (!_isPicking) return;

    _isPicking = false;

    // Save the last picked color to history
    await StorageService.addColorToHistory(_currentColor);

    notifyListeners();
  }

  void updateColor() {
    if (!_isPicking) return;

    final point = calloc<POINT>();
    try {
      GetCursorPos(point);
      final hdc = GetDC(NULL);
      final colorRef = GetPixel(hdc, point.ref.x, point.ref.y);
      ReleaseDC(NULL, hdc);

      if (colorRef != clrInvalid) {
        final r = GetRValue(colorRef);
        final g = GetGValue(colorRef);
        final b = GetBValue(colorRef);
        _currentColor = Color(0xFF000000 | (r << 16) | (g << 8) | b);
        notifyListeners();
      }
    } finally {
      calloc.free(point);
    }
  }

  Map<String, double> rgbToCmyk(Color color) {
    final r = ((color.value >> 16) & 0xFF) / 255.0;
    final g = ((color.value >> 8) & 0xFF) / 255.0;
    final b = (color.value & 0xFF) / 255.0;

    final k = 1 - [r, g, b].reduce((a, b) => a > b ? a : b);
    final c = k == 1 ? 0 : (1 - r - k) / (1 - k);
    final m = k == 1 ? 0 : (1 - g - k) / (1 - k);
    final y = k == 1 ? 0 : (1 - b - k) / (1 - k);

    return {
      'c': (c * 100).round().toDouble(),
      'm': (m * 100).round().toDouble(),
      'y': (y * 100).round().toDouble(),
      'k': (k * 100).round().toDouble(),
    };
  }

  @override
  void dispose() {
    stopPicking();
    super.dispose();
  }
} 