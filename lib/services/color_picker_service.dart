import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:win32/win32.dart';

class ColorPickerService {
  static final ColorPickerService _instance = ColorPickerService._internal();
  factory ColorPickerService() => _instance;
  ColorPickerService._internal();

  bool _isActive = false;
  Color _currentColor = Colors.white;
  final _callbacks = <Function(Color)>[];

  bool get isActive => _isActive;
  Color get currentColor => _currentColor;

  void addListener(Function(Color) callback) {
    _callbacks.add(callback);
  }

  void removeListener(Function(Color) callback) {
    _callbacks.remove(callback);
  }

  void _notifyListeners() {
    for (var callback in _callbacks) {
      callback(_currentColor);
    }
  }

  void startPicking() {
    if (!_isActive) {
      _isActive = true;
      _startColorCapture();
    }
  }

  void stopPicking() {
    _isActive = false;
  }

  Future<void> _startColorCapture() async {
    while (_isActive) {
      try {
        final point = calloc<POINT>();
        int? hdc;

        try {
          if (GetCursorPos(point) != 0) {
            hdc = GetDC(NULL);
            if (hdc != 0) {
              final color = GetPixel(hdc, point.ref.x, point.ref.y);
              
              if (color != -1) {  // -1 is CLR_INVALID in Win32
                final newColor = Color.fromRGBO(
                  GetRValue(color),
                  GetGValue(color),
                  GetBValue(color),
                  1.0,
                );

                if (newColor != _currentColor) {
                  _currentColor = newColor;
                  _notifyListeners();
                }
              }
            }
          }
        } finally {
          if (hdc != null && hdc != 0) {
            ReleaseDC(NULL, hdc);
          }
          free(point);
        }

        await Future.delayed(const Duration(milliseconds: 16)); // ~60fps
      } catch (e) {
        debugPrint('Error capturing color: $e');
        await Future.delayed(const Duration(milliseconds: 100)); // Delay on error
      }
    }
  }

  // Convert RGB to CMYK
  Map<String, double> rgbToCmyk(Color color) {
    double r = color.red / 255;
    double g = color.green / 255;
    double b = color.blue / 255;

    double k = 1 - [r, g, b].reduce((a, b) => a > b ? a : b);
    if (k == 1) {
      return {
        'c': 0,
        'm': 0,
        'y': 0,
        'k': 100,
      };
    }

    double c = (1 - r - k) / (1 - k);
    double m = (1 - g - k) / (1 - k);
    double y = (1 - b - k) / (1 - k);

    return {
      'c': (c * 100).roundToDouble(),
      'm': (m * 100).roundToDouble(),
      'y': (y * 100).roundToDouble(),
      'k': (k * 100).roundToDouble(),
    };
  }
} 