class HoldingModel {
  final String symbol;
  int quantity;
  int avgCostPaise;

  HoldingModel({
    required this.symbol,
    required this.quantity,
    required this.avgCostPaise,
  });

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'quantity': quantity,
        'avgCostPaise': avgCostPaise,
      };

  factory HoldingModel.fromJson(Map<String, dynamic> json) => HoldingModel(
        symbol: json['symbol'] as String,
        quantity: json['quantity'] as int,
        avgCostPaise: json['avgCostPaise'] as int,
      );
}

class HoldingRow {
  final String symbol;
  final int quantity;
  final int avgCostPaise;
  final int ltpPaise;

  const HoldingRow({
    required this.symbol,
    required this.quantity,
    required this.avgCostPaise,
    required this.ltpPaise,
  });

  int get investedPaise => avgCostPaise * quantity;
  int get currentValuePaise => ltpPaise * quantity;
  int get pnlPaise => currentValuePaise - investedPaise;
  double get pnlPercent =>
      investedPaise == 0 ? 0 : (pnlPaise / investedPaise) * 100;
}
