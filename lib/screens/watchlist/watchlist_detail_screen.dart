import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/watchlist_provider.dart';
import '../../core/services/market_data_service.dart';
import '../../widgets/stock_row_tile.dart';
import '../ticket/buy_sell_ticket_screen.dart';
import 'stock_picker_sheet.dart';

class WatchlistDetailScreen extends StatelessWidget {
  const WatchlistDetailScreen({super.key, required this.watchlistId});

  final String watchlistId;

  @override
  Widget build(BuildContext context) {
    final market = context.read<MarketDataService>();

    return Consumer<WatchlistProvider>(
      builder: (context, provider, _) {
        final watchlist = provider.byId(watchlistId);
        if (watchlist == null) {
          // Watchlist was deleted (e.g. from another screen) — bail out.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(context)) Navigator.pop(context);
          });
          return const Scaffold(body: SizedBox.shrink());
        }

        return Scaffold(
          appBar: AppBar(title: Text(watchlist.name)),
          body: watchlist.symbols.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('This watchlist is empty'),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => _addStock(context, watchlist.symbols),
                        icon: const Icon(Icons.add),
                        label: const Text('Add a stock'),
                      ),
                    ],
                  ),
                )
              : ReorderableListView.builder(
                  itemCount: watchlist.symbols.length,
                  onReorder: (oldIndex, newIndex) {
                    context.read<WatchlistProvider>().reorder(watchlistId, oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final symbol = watchlist.symbols[index];
                    return Dismissible(
                      key: ValueKey('${watchlist.id}_$symbol'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        context.read<WatchlistProvider>().removeStock(watchlistId, symbol);
                      },
                      child: StockRowTile(
                        key: ValueKey('tile_${watchlist.id}_$symbol'),
                        symbol: symbol,
                        market: market,
                        dragHandle: ReorderableDragStartListener(
                          index: index,
                          child: const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(Icons.drag_handle, color: Colors.grey),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BuySellTicketScreen(symbol: symbol),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addStock(context, watchlist.symbols),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Future<void> _addStock(BuildContext context, List<String> current) async {
    final symbol = await showStockPickerSheet(context, alreadyAdded: current);
    if (symbol != null && context.mounted) {
      context.read<WatchlistProvider>().addStock(watchlistId, symbol);
    }
  }
}
