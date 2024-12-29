import 'package:flutter/material.dart';
import '../models/color_history_entry.dart';
import '../services/storage_service.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  final Function(String) onCopy;

  const HistoryPage({
    super.key,
    required this.onCopy,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'History',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              FilledButton.tonalIcon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear History'),
                      content: const Text('Are you sure you want to clear all history?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () {
                            StorageService.clearColorHistory();
                            setState(() {});
                            Navigator.of(context).pop();
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear History'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: FutureBuilder<List<ColorHistoryEntry>>(
                future: StorageService.loadColorHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No colors in history',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final entry = snapshot.data![index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _ColorHistoryTile(
                          entry: entry,
                          onCopy: widget.onCopy,
                          onDelete: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Color'),
                                content: const Text('Are you sure you want to delete this color from history?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () {
                                      StorageService.removeFromHistory(entry);
                                      setState(() {});
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorHistoryTile extends StatelessWidget {
  final ColorHistoryEntry entry;
  final Function(String) onCopy;
  final VoidCallback onDelete;

  const _ColorHistoryTile({
    required this.entry,
    required this.onCopy,
    required this.onDelete,
  });

  String _getCmykString() {
    final colorValue = entry.color.value;
    final r = ((colorValue >> 16) & 0xFF) / 255.0;
    final g = ((colorValue >> 8) & 0xFF) / 255.0;
    final b = (colorValue & 0xFF) / 255.0;

    final k = 1 - [r, g, b].reduce((a, b) => a > b ? a : b);
    final c = k == 1 ? 0 : ((1 - r - k) / (1 - k) * 100).round();
    final m = k == 1 ? 0 : ((1 - g - k) / (1 - k) * 100).round();
    final y = k == 1 ? 0 : ((1 - b - k) / (1 - k) * 100).round();
    final kPercent = (k * 100).round();

    return 'CMYK($c%, $m%, $y%, $kPercent%)';
  }

  @override
  Widget build(BuildContext context) {
    // Get raw RGB values from color
    final colorValue = entry.color.value;
    final r = (colorValue >> 16) & 0xFF;
    final g = (colorValue >> 8) & 0xFF;
    final b = colorValue & 0xFF;
    
    final hexColor = '#${r.toRadixString(16).padLeft(2, '0')}'
                    '${g.toRadixString(16).padLeft(2, '0')}'
                    '${b.toRadixString(16).padLeft(2, '0')}';
    final rgbColor = 'RGB($r, $g, $b)';
    final cmykColor = _getCmykString();
    final dateStr = DateFormat('MMM d, y h:mm a').format(entry.timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  dateStr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: entry.color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withAlpha(128),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ColorValueRow(
                        label: 'HEX',
                        value: hexColor.toUpperCase(),
                        onCopy: onCopy,
                      ),
                      const SizedBox(height: 4),
                      _ColorValueRow(
                        label: 'RGB',
                        value: rgbColor,
                        onCopy: onCopy,
                      ),
                      const SizedBox(height: 4),
                      _ColorValueRow(
                        label: 'CMYK',
                        value: cmykColor,
                        onCopy: onCopy,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                  tooltip: 'Delete from history',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorValueRow extends StatelessWidget {
  final String label;
  final String value;
  final Function(String) onCopy;

  const _ColorValueRow({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 45,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 16),
                onPressed: () => onCopy(value),
                visualDensity: VisualDensity.compact,
                tooltip: 'Copy $label value',
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 