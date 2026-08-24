import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/models/order.dart';
import '../../core/money.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final isBuy = order.side == OrderSide.buy;
    return Scaffold(
      appBar: AppBar(title: const Text('Order Confirmed'), automaticallyImplyLeading: false),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600, size: 72),
              const SizedBox(height: 16),
              Text(
                '${isBuy ? 'Bought' : 'Sold'} ${order.quantity} × ${order.symbol}',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text('at ${Money(order.pricePaise).formatted} per share'),
              const SizedBox(height: 4),
              Text(
                'Total: ${Money(order.valuePaise).formatted}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('d MMM yyyy, h:mm a').format(order.timestamp),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
