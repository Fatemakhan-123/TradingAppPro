import 'package:flutter/material.dart';

import '../../core/models/stock.dart';

Future<String?> showStockPickerSheet(
  BuildContext context, {
  required List<String> alreadyAdded,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollController) {
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Add a stock', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: kStockUniverse.length,
                  itemBuilder: (context, index) {
                    final s = kStockUniverse[index];
                    final added = alreadyAdded.contains(s.symbol);
                    return ListTile(
                      enabled: !added,
                      title: Text(s.symbol, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(s.name),
                      trailing: added ? const Icon(Icons.check_circle, color: Colors.green) : null,
                      onTap: added ? null : () => Navigator.pop(ctx, s.symbol),
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
