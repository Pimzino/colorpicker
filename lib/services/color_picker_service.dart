import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:win32/win32.dart';

class ColorPickerService extends ChangeNotifier {
  bool _isActive = false;
  Color _currentColor = Colors.white;
  static const int CLR_INVALID = 0xFFFFFFFF;

  bool get isActive => _isActive;
  Color get currentColor => _currentColor;

  void startPicking() {
    _isActive = true;
    notifyListeners();
  }

  void stopPicking() {
    _isActive = false;
    notifyListeners();
  }

  void updateColor() {
    if (!_isActive) return;

    final point = calloc<POINT>();
    try {
      GetCursorPos(point);
      final hdc = GetDC(NULL);
      final colorRef = GetPixel(hdc, point.ref.x, point.ref.y);
      ReleaseDC(NULL, hdc);

      if (colorRef != CLR_INVALID) {
        _currentColor = Color.fromARGB(
          255,
          GetRValue(colorRef),
          GetGValue(colorRef),
          GetBValue(colorRef),
        );
        notifyListeners();
      }
    } finally {
      calloc.free(point);
    }
  }

  Map<String, double> rgbToCmyk(Color color) {
    double r = color.red / 255;
    double g = color.green / 255;
    double b = color.blue / 255;

    double k = 1 - [r, g, b].reduce((a, b) => a > b ? a : b);
    double c = k == 1 ? 0 : (1 - r - k) / (1 - k);
    double m = k == 1 ? 0 : (1 - g - k) / (1 - k);
    double y = k == 1 ? 0 : (1 - b - k) / (1 - k);

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