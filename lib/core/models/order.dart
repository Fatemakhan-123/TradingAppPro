enum OrderSide { buy, sell }

class OrderModel {
  final String id;
  final String symbol;
  final OrderSide side;
  final int quantity;
  final int pricePaise;
  final int valuePaise;
  final DateTime timestamp;

  const OrderModel({
    required this.id,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.pricePaise,
    required this.valuePaise,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'symbol': symbol,
        'side': side.name,
        'quantity': quantity,
        'pricePaise': pricePaise,
        'valuePaise': valuePaise,
        'timestamp': timestamp.toIso8601String(),
      };

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as String,
        symbol: json['symbol'] as String,
        side: OrderSide.values.firstWhere((e) => e.name == json['side']),
        quantity: json['quantity'] as int,
        pricePaise: json['pricePaise'] as int,
        valuePaise: json['valuePaise'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
