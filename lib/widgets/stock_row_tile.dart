import 'package:flutter/material.dart';

import '../core/app_colors/app_colors.dart';
import '../core/models/stock.dart';
import '../core/services/market_data_service.dart';
import 'flash_price_cell.dart';

class StockRowTile extends StatelessWidget {
  const StockRowTile({
    super.key,
    required this.symbol,
    required this.market,
    this.onTap,
    this.trailingLeadingWidget,
    this.dragHandle,
  });

  final String symbol;
  final MarketDataService market;
  final VoidCallback? onTap;
  final Widget? trailingLeadingWidget;
  final Widget? dragHandle;

  @override
  Widget build(BuildContext context) {
    final info = kStockUniverseBySymbol[symbol];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (dragHandle != null) ...[
                  dragHandle!,
                  const SizedBox(width: 8),
                ],
                // Stock symbol circle
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    symbol[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Stock info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        symbol,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.textDarkPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        info?.name ?? symbol,
                        style: const TextStyle(
                          color: AppColors.textDarkSecondary,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Price
                if (trailingLeadingWidget != null) ...[
                  trailingLeadingWidget!,
                  const SizedBox(width: 8),
                ],
                FlashPriceCell(quoteListenable: market.quoteNotifier(symbol)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
