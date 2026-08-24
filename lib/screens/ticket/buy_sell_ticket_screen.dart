import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/order.dart';
import '../../core/models/stock.dart';
import '../../core/money.dart';
import '../../core/providers/holdings_provider.dart';
import '../../core/providers/orders_provider.dart';
import '../../core/providers/wallet_provider.dart';
import '../../core/services/market_data_service.dart';
import 'order_confirmation_screen.dart';

class BuySellTicketScreen extends StatefulWidget {
  const BuySellTicketScreen({super.key, required this.symbol});

  final String symbol;

  @override
  State<BuySellTicketScreen> createState() => _BuySellTicketScreenState();
}

class _BuySellTicketScreenState extends State<BuySellTicketScreen> {
  OrderSide _side = OrderSide.buy;
  final _qtyController = TextEditingController(text: '1');
  String? _error;
  bool _submitting = false;

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  int? get _quantity {
    final text = _qtyController.text.trim();
    if (text.isEmpty) return null;
    // Only accept a clean positive integer — this alone rejects fractional
    // ("1.5"), negative ("-1", via the sign check below) and non-numeric input.
    final value = int.tryParse(text);
    return value;
  }

  String? _validate(int ltpPaise, int heldQty, int balancePaise) {
    final qty = _quantity;
    if (qty == null) return 'Enter a whole number quantity';
    if (qty <= 0) return 'Quantity must be greater than zero';

    if (_side == OrderSide.buy) {
      final orderValue = ltpPaise * qty;
      if (orderValue > balancePaise) {
        return 'Order value ${Money(orderValue).formatted} exceeds available '
            'balance ${Money(balancePaise).formatted}';
      }
    } else {
      if (qty > heldQty) {
        return 'You only hold $heldQty share${heldQty == 1 ? '' : 's'} of ${widget.symbol}';
      }
    }
    return null;
  }

  Future<void> _submit(int ltpPaise, int heldQty, int balancePaise) async {
    final error = _validate(ltpPaise, heldQty, balancePaise);
    setState(() => _error = error);
    if (error != null) return;

    setState(() => _submitting = true);
    final qty = _quantity!;
    final orderValuePaise = ltpPaise * qty;

    final holdings = context.read<HoldingsProvider>();
    final wallet = context.read<WalletProvider>();
    final orders = context.read<OrdersProvider>();

    if (_side == OrderSide.buy) {
      await wallet.debit(orderValuePaise);
      await holdings.applyBuy(widget.symbol, qty, ltpPaise);
    } else {
      final ok = await holdings.applySell(widget.symbol, qty);
      if (!ok) {
        setState(() {
          _submitting = false;
          _error = 'Sell failed — insufficient quantity held';
        });
        return;
      }
      await wallet.credit(orderValuePaise);
    }

    final order = await orders.recordOrder(
      symbol: widget.symbol,
      side: _side,
      quantity: qty,
      pricePaise: ltpPaise,
    );

    if (!mounted) return;
    setState(() => _submitting = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => OrderConfirmationScreen(order: order)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final market = context.read<MarketDataService>();
    final info = kStockUniverseBySymbol[widget.symbol];

    return Scaffold(
      appBar: AppBar(title: Text('${widget.symbol} · Buy/Sell')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ValueListenableBuilder<Quote>(
          // Live LTP on the ticket updates as ticks arrive while the form is open.
          valueListenable: market.quoteNotifier(widget.symbol),
          builder: (context, quote, _) {
            return Consumer2<WalletProvider, HoldingsProvider>(
              builder: (context, wallet, holdings, _) {
                final heldQty = holdings.quantityHeld(widget.symbol);
                final qty = _quantity ?? 0;
                final orderValuePaise = quote.ltpPaise * (qty > 0 ? qty : 0);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(info?.name ?? widget.symbol, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          Money(quote.ltpPaise).formatted,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${quote.changePaise >= 0 ? '+' : ''}${quote.changePercent.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: quote.changePaise >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SegmentedButton<OrderSide>(
                      segments: const [
                        ButtonSegment(value: OrderSide.buy, label: Text('Buy')),
                        ButtonSegment(value: OrderSide.sell, label: Text('Sell')),
                      ],
                      selected: {_side},
                      onSelectionChanged: (s) => setState(() {
                        _side = s.first;
                        _error = null;
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() => _error = null),
                    ),
                    const SizedBox(height: 8),
                    Text('Currently held: $heldQty share${heldQty == 1 ? '' : 's'}',
                        style: const TextStyle(color: Colors.grey)),
                    Text('Available balance: ${wallet.balance.formatted}',
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    Card(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Order value'),
                            Text(
                              Money(orderValuePaise).formatted,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: _side == OrderSide.buy ? Colors.green.shade700 : Colors.red.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _submitting
                            ? null
                            : () => _submit(quote.ltpPaise, heldQty, wallet.balancePaise),
                        child: Text(_submitting
                            ? 'Placing order...'
                            : '${_side == OrderSide.buy ? 'Buy' : 'Sell'} ${widget.symbol}'),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
