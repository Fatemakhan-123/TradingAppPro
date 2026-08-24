import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/holding.dart';
import '../services/market_data_service.dart';
import '../services/persistence_service.dart';

enum HoldingsSortField { pnl, symbol, currentValue }


class HoldingsProvider extends ChangeNotifier {
  HoldingsProvider(this._persistence, this._market);

  final PersistenceService _persistence;
  final MarketDataService _market;

  Map<String, HoldingModel> _holdings = {};
  List<HoldingRow> _rows = [];
  Timer? _pollTimer;

  HoldingsSortField _sortField = HoldingsSortField.pnl;
  bool _descending = true;

  List<HoldingRow> get rows => List.unmodifiable(_rows);
  HoldingsSortField get sortField => _sortField;
  bool get descending => _descending;
  bool get isEmpty => _holdings.isEmpty;

  int get totalInvestedPaise => _rows.fold(0, (sum, r) => sum + r.investedPaise);
  int get totalCurrentValuePaise => _rows.fold(0, (sum, r) => sum + r.currentValuePaise);
  int get totalPnlPaise => totalCurrentValuePaise - totalInvestedPaise;
  double get totalPnlPercent =>
      totalInvestedPaise == 0 ? 0 : (totalPnlPaise / totalInvestedPaise) * 100;

  void load() {
    _holdings = _persistence.loadHoldings();
    _recompute(forceNotify: true);
    _startPolling();
  }

  int quantityHeld(String symbol) => _holdings[symbol]?.quantity ?? 0;

  Future<void> applyBuy(String symbol, int quantity, int pricePaise) async {
    final existing = _holdings[symbol];
    if (existing == null) {
      _holdings[symbol] = HoldingModel(
        symbol: symbol,
        quantity: quantity,
        avgCostPaise: pricePaise,
      );
    } else {
      final newQty = existing.quantity + quantity;
      // Weighted average cost, integer math throughout.
      final newAvg =
          ((existing.avgCostPaise * existing.quantity) + (pricePaise * quantity)) ~/ newQty;
      existing.quantity = newQty;
      existing.avgCostPaise = newAvg;
    }
    await _persistAndRecompute();
  }

  Future<bool> applySell(String symbol, int quantity) async {
    final existing = _holdings[symbol];
    if (existing == null || existing.quantity < quantity) return false;
    existing.quantity -= quantity;
    if (existing.quantity == 0) {
      _holdings.remove(symbol);
    }
    await _persistAndRecompute();
    return true;
  }

  void setSort(HoldingsSortField field, {bool? descending}) {
    if (_sortField == field && descending == null) {
      _descending = !_descending;
    } else {
      _sortField = field;
      _descending = descending ?? true;
    }
    _sortRows();
    notifyListeners();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      _recompute();
    });
  }

  Future<void> _persistAndRecompute() async {
    _recompute(forceNotify: true);
    await _persistence.saveHoldings(_holdings);
  }

  void _recompute({bool forceNotify = false}) {
    final newRows = <HoldingRow>[
      for (final h in _holdings.values)
        HoldingRow(
          symbol: h.symbol,
          quantity: h.quantity,
          avgCostPaise: h.avgCostPaise,
          ltpPaise: _market.currentQuote(h.symbol).ltpPaise,
        ),
    ];

    final changed = forceNotify || _rowsDiffer(newRows);
    _rows = newRows;
    if (changed) {
      _sortRows();
      notifyListeners();
    }
  }

  bool _rowsDiffer(List<HoldingRow> newRows) {
    if (newRows.length != _rows.length) return true;
    final byOldSymbol = {for (final r in _rows) r.symbol: r};
    for (final r in newRows) {
      final old = byOldSymbol[r.symbol];
      if (old == null || old.ltpPaise != r.ltpPaise || old.quantity != r.quantity) {
        return true;
      }
    }
    return false;
  }

  void _sortRows() {
    int Function(HoldingRow, HoldingRow) cmp;
    switch (_sortField) {
      case HoldingsSortField.symbol:
        cmp = (a, b) => a.symbol.compareTo(b.symbol);
        break;
      case HoldingsSortField.currentValue:
        cmp = (a, b) => a.currentValuePaise.compareTo(b.currentValuePaise);
        break;
      case HoldingsSortField.pnl:
        cmp = (a, b) => a.pnlPaise.compareTo(b.pnlPaise);
        break;
    }
    _rows.sort(_descending ? (a, b) => cmp(b, a) : cmp);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
