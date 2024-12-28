import 'package:flutter/material.dart';
import '../layout/section_layout.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionLayout(
      title: 'About',
      children: const [
        Text(
          'Color Picker v1.0.0',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Text(
          'A modern desktop color picker application for Windows and macOS.',
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 24),
        Text(
          '© 2024 Color Picker',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
} 