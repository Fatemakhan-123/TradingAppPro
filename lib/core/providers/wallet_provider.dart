import 'package:flutter/foundation.dart';

import '../money.dart';
import '../services/persistence_service.dart';

class WalletProvider extends ChangeNotifier {
  WalletProvider(this._persistence);

  final PersistenceService _persistence;

  int _balancePaise = 0;
  int get balancePaise => _balancePaise;
  Money get balance => Money(_balancePaise);

  void load() {
    _balancePaise = _persistence.loadWalletBalancePaise();
    notifyListeners();
  }

  bool canAfford(int valuePaise) => valuePaise <= _balancePaise;

  Future<void> debit(int valuePaise) async {
    _balancePaise -= valuePaise;
    await _persist();
  }

  Future<void> credit(int valuePaise) async {
    _balancePaise += valuePaise;
    await _persist();
  }

  Future<void> _persist() async {
    notifyListeners();
    await _persistence.saveWalletBalancePaise(_balancePaise);
  }
}
