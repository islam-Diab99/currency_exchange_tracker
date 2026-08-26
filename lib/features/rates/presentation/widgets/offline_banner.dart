import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Thin strip shown above the rates list when data is stale (offline or served
/// from cache), telling the user how fresh the numbers they're seeing are.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.lastUpdated});
  final DateTime lastUpdated;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: scheme.tertiaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 18,
            color: scheme.onTertiaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Offline — showing saved rates from '
              '${DateFormat('MMM d, HH:mm').format(lastUpdated)}',
              style: TextStyle(
                color: scheme.onTertiaryContainer,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
