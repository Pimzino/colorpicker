import 'package:flutter/material.dart';

class SectionLayout extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsets padding;
  final double spacing;

  const SectionLayout({
    super.key,
    required this.title,
    required this.children,
    this.padding = const EdgeInsets.all(24.0),
    this.spacing = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: spacing),
            ...children,
          ],
        ),
      ),
    );
  }
} 