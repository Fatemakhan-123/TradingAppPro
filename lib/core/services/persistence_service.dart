import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/holding.dart';
import '../models/order.dart';
import '../models/watchlist.dart';

/// Thin persistence layer over SharedPreferences. Everything is stored as
/// JSON strings under a handful of well-known keys. There's no real backend
/// per the assignment, so this is the durable store across app restarts.
class PersistenceService {
  static const _kWatchlists = 'watchlists_v1';
  static const _kWalletBalance = 'wallet_balance_paise_v1';
  static const _kHoldings = 'holdings_v1';
  static const _kOrders = 'orders_v1';

  static const int startingBalancePaise = 100000000; // ₹10,00,000 seed capital

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ---------------- Watchlists ----------------
  List<WatchlistModel> loadWatchlists() {
    final raw = _prefs.getString(_kWatchlists);
    if (raw == null) return _defaultWatchlists();
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => WatchlistModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveWatchlists(List<WatchlistModel> watchlists) async {
    final raw = jsonEncode(watchlists.map((w) => w.toJson()).toList());
    await _prefs.setString(_kWatchlists, raw);
  }

  List<WatchlistModel> _defaultWatchlists() => [
        WatchlistModel(id: 'default', name: 'My Watchlist', symbols: [
          'RELIANCE',
          'TCS',
          'INFY',
          'HDFCBANK',
        ]),
      ];

  // ---------------- Wallet ----------------
  int loadWalletBalancePaise() {
    return _prefs.getInt(_kWalletBalance) ?? startingBalancePaise;
  }

  Future<void> saveWalletBalancePaise(int paise) async {
    await _prefs.setInt(_kWalletBalance, paise);
  }

  // ---------------- Holdings ----------------
  Map<String, HoldingModel> loadHoldings() {
    final raw = _prefs.getString(_kHoldings);
    if (raw == null) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map(
      (key, value) => MapEntry(key, HoldingModel.fromJson(value as Map<String, dynamic>)),
    );
  }

  Future<void> saveHoldings(Map<String, HoldingModel> holdings) async {
    final raw = jsonEncode(holdings.map((key, value) => MapEntry(key, value.toJson())));
    await _prefs.setString(_kHoldings, raw);
  }

  // ---------------- Orders ----------------
  List<OrderModel> loadOrders() {
    final raw = _prefs.getString(_kOrders);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveOrders(List<OrderModel> orders) async {
    final raw = jsonEncode(orders.map((o) => o.toJson()).toList());
    await _prefs.setString(_kOrders, raw);
  }
}
