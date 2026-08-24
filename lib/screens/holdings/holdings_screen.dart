import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors/app_colors.dart';
import '../../core/models/holding.dart';
import '../../core/models/stock.dart';
import '../../core/money.dart';
import '../../core/providers/holdings_provider.dart';
import '../ticket/buy_sell_ticket_screen.dart';

class HoldingsScreen extends StatelessWidget {
  const HoldingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Holdings'),
        elevation: 0,
        actions: [
          Consumer<HoldingsProvider>(
            builder: (context, holdings, _) {
              return PopupMenuButton<HoldingsSortField>(
                icon: const Icon(Icons.tune_rounded, size: 24),
                tooltip: 'Sort',
                onSelected: (field) => holdings.setSort(field),
                itemBuilder: (ctx) => [
                  _sortItem(holdings, HoldingsSortField.pnl, 'P&L'),
                  _sortItem(holdings, HoldingsSortField.symbol, 'Symbol'),
                  _sortItem(holdings, HoldingsSortField.currentValue, 'Current Value'),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<HoldingsProvider>(
        builder: (context, holdings, _) {
          if (holdings.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryColor.withOpacity(0.1),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Icon(
                        Icons.trending_up_rounded,
                        size: 48,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No Holdings Yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDarkPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Start trading to build your portfolio',
                      style: TextStyle(
                        color: AppColors.textDarkSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _AggregateSummary(holdings: holdings),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final row = holdings.rows[index];
                      return _HoldingRowTile(row: row);
                    },
                    childCount: holdings.rows.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  PopupMenuItem<HoldingsSortField> _sortItem(
      HoldingsProvider holdings, HoldingsSortField field, String label) {
    final active = holdings.sortField == field;
    return PopupMenuItem(
      value: field,
      child: Row(
        children: [
          if (active)
            Icon(
              holdings.descending ? Icons.arrow_downward : Icons.arrow_upward,
              size: 16,
              color: AppColors.primaryColor,
            ),
          if (active) const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              color: active ? AppColors.primaryColor : AppColors.textDarkPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AggregateSummary extends StatelessWidget {
  const _AggregateSummary({required this.holdings});

  final HoldingsProvider holdings;

  @override
  Widget build(BuildContext context) {
    final pnl = Money(holdings.totalPnlPaise);
    final up = holdings.totalPnlPaise >= 0;

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: up ? AppColors.successGradient : AppColors.errorGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (up ? const Color(0xFF10B981) : const Color(0xFFF4433))
                .withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Portfolio Value',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        up ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${up ? '+' : ''}${holdings.totalPnlPercent.toStringAsFixed(2)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              Money(holdings.totalCurrentValuePaise).formatted,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _summaryItem(
                    'Invested',
                    Money(holdings.totalInvestedPaise).formatted,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _summaryItem(
                    'Profit/Loss',
                    '${up ? '+' : ''}${pnl.formattedPlain}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _HoldingRowTile extends StatelessWidget {
  const _HoldingRowTile({required this.row});

  final HoldingRow row;

  @override
  Widget build(BuildContext context) {
    final info = kStockUniverseBySymbol[row.symbol];
    final up = row.pnlPaise >= 0;
    final pnlColor = up ? AppColors.successColor : AppColors.errorColor;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BuySellTicketScreen(symbol: row.symbol),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Stock icon circle
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryColor.withOpacity(0.1),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    row.symbol[0],
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
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
                        row.symbol,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.textDarkPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${row.quantity} shares · Avg ${Money(row.avgCostPaise).formatted}',
                        style: const TextStyle(
                          color: AppColors.textDarkSecondary,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (info != null)
                        Text(
                          info.name,
                          style: const TextStyle(
                            color: AppColors.textDarkSecondary,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Profit/Loss
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Money(row.currentValuePaise).formatted,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.textDarkPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        '${up ? '+' : ''}${Money(row.pnlPaise).formattedPlain} (${up ? '+' : ''}${row.pnlPercent.toStringAsFixed(2)}%)',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
