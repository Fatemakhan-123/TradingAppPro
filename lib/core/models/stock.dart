
class StockInfo {
  final String symbol;
  final String name;
  final int basePricePaise;

  const StockInfo({
    required this.symbol,
    required this.name,
    required this.basePricePaise,
  });
}

const List<StockInfo> kStockUniverse = [
  StockInfo(symbol: 'RELIANCE', name: 'Reliance Industries', basePricePaise: 292045),
  StockInfo(symbol: 'TCS', name: 'Tata Consultancy Services', basePricePaise: 384560),
  StockInfo(symbol: 'INFY', name: 'Infosys', basePricePaise: 178230),
  StockInfo(symbol: 'HDFCBANK', name: 'HDFC Bank', basePricePaise: 165410),
  StockInfo(symbol: 'ICICIBANK', name: 'ICICI Bank', basePricePaise: 121875),
  StockInfo(symbol: 'SBIN', name: 'State Bank of India', basePricePaise: 82015),
  StockInfo(symbol: 'ITC', name: 'ITC Limited', basePricePaise: 46830),
  StockInfo(symbol: 'LT', name: 'Larsen & Toubro', basePricePaise: 359020),
  StockInfo(symbol: 'BHARTIARTL', name: 'Bharti Airtel', basePricePaise: 158940),
  StockInfo(symbol: 'AXISBANK', name: 'Axis Bank', basePricePaise: 111260),
];

final Map<String, StockInfo> kStockUniverseBySymbol = {
  for (final s in kStockUniverse) s.symbol: s,
};

enum TickDirection { up, down, none }

class Quote {
  final int ltpPaise;
  final int prevClosePaise;
  final TickDirection direction;
  final DateTime updatedAt;

  const Quote({
    required this.ltpPaise,
    required this.prevClosePaise,
    required this.direction,
    required this.updatedAt,
  });

  int get changePaise => ltpPaise - prevClosePaise;

  double get changePercent =>
      prevClosePaise == 0 ? 0 : (changePaise / prevClosePaise) * 100;

  Quote copyWith({int? ltpPaise, TickDirection? direction, DateTime? updatedAt}) {
    return Quote(
      ltpPaise: ltpPaise ?? this.ltpPaise,
      prevClosePaise: prevClosePaise,
      direction: direction ?? this.direction,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
