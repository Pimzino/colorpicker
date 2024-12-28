import 'package:flutter/material.dart';

class PageLayout extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsets padding;

  const PageLayout({
    super.key,
    required this.title,
    required this.children,
    this.padding = const EdgeInsets.all(24.0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }
} 