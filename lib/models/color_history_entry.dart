import 'dart:ui';
import 'package:flutter/material.dart' show Colors;

class ColorHistoryEntry {
  final Color color;
  final DateTime timestamp;

  ColorHistoryEntry({
    required this.color,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'color': color.value & 0xFFFFFF,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ColorHistoryEntry.fromJson(Map<String, dynamic> json) {
    try {
      // Handle new format (single integer)
      if (json['color'] is int) {
        return ColorHistoryEntry(
          color: Color(0xFF000000 | (json['color'] as int)),
          timestamp: DateTime.parse(json['timestamp'] as String),
        );
      }
      
      // Handle old format (map with RGBA)
      final colorMap = json['color'] as Map<String, dynamic>;
      final r = colorMap['r'] as int;
      final g = colorMap['g'] as int;
      final b = colorMap['b'] as int;
      
      return ColorHistoryEntry(
        color: Color(0xFF000000 | (r << 16) | (g << 8) | b),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
    } catch (e) {
      // If anything goes wrong, return a default color
      return ColorHistoryEntry(
        color: Colors.white,
        timestamp: DateTime.now(),
      );
    }
  }
} 