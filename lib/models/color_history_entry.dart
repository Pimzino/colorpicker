import 'dart:ui';

class ColorHistoryEntry {
  final Color color;
  final DateTime timestamp;

  ColorHistoryEntry({
    required this.color,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'color': (color.a.toInt() << 24) | (color.r.toInt() << 16) | (color.g.toInt() << 8) | color.b.toInt(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ColorHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ColorHistoryEntry(
      color: Color(json['color'] as int),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
} 