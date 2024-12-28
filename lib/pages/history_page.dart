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
  Future<void> _deleteHistoryEntry(ColorHistoryEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Color'),
        content: const Text('Are you sure you want to delete this color from history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.removeFromHistory(entry);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Color deleted from history'),
            behavior: SnackBarBehavior.floating,
            width: 200,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ColorHistoryEntry>>(
      future: StorageService.loadColorHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final history = snapshot.data ?? [];

        return Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Color History',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (history.isNotEmpty)
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Clear History'),
                            content: const Text('Are you sure you want to clear your color history?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          await StorageService.clearColorHistory();
                          if (mounted) {
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Color history cleared'),
                                behavior: SnackBarBehavior.floating,
                                width: 200,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Clear History'),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              if (history.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No colors in history',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Colors will appear here when you pick them',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final entry = history[index];
                      return _ColorHistoryTile(
                        entry: entry,
                        onCopy: widget.onCopy,
                        onDelete: () => _deleteHistoryEntry(entry),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
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
    final r = entry.color.red / 255;
    final g = entry.color.green / 255;
    final b = entry.color.blue / 255;

    final k = 1 - [r, g, b].reduce((a, b) => a > b ? a : b);
    final c = k == 1 ? 0 : ((1 - r - k) / (1 - k) * 100).round();
    final m = k == 1 ? 0 : ((1 - g - k) / (1 - k) * 100).round();
    final y = k == 1 ? 0 : ((1 - b - k) / (1 - k) * 100).round();
    final kPercent = (k * 100).round();

    return 'CMYK($c%, $m%, $y%, $kPercent%)';
  }

  @override
  Widget build(BuildContext context) {
    final hexColor = '#${entry.color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
    final rgbColor = 'RGB(${entry.color.red}, ${entry.color.green}, ${entry.color.blue})';
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
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
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