import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/order.dart';
import '../services/persistence_service.dart';

class OrdersProvider extends ChangeNotifier {
  OrdersProvider(this._persistence);

  final PersistenceService _persistence;
  final _uuid = const Uuid();

  List<OrderModel> _orders = [];
  List<OrderModel> get orders => List.unmodifiable(_orders.reversed);

  void load() {
    _orders = _persistence.loadOrders();
    notifyListeners();
  }

  Future<OrderModel> recordOrder({
    required String symbol,
    required OrderSide side,
    required int quantity,
    required int pricePaise,
  }) async {
    final order = OrderModel(
      id: _uuid.v4(),
      symbol: symbol,
      side: side,
      quantity: quantity,
      pricePaise: pricePaise,
      valuePaise: pricePaise * quantity,
      timestamp: DateTime.now(),
    );
    _orders.add(order);
    notifyListeners();
    await _persistence.saveOrders(_orders);
    return order;
  }
}
