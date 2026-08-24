import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/watchlist.dart';
import '../services/persistence_service.dart';

class WatchlistProvider extends ChangeNotifier {
  WatchlistProvider(this._persistence);

  final PersistenceService _persistence;
  final _uuid = const Uuid();

  List<WatchlistModel> _watchlists = [];
  List<WatchlistModel> get watchlists => List.unmodifiable(_watchlists);

  bool _loaded = false;
  bool get loaded => _loaded;

  void load() {
    _watchlists = _persistence.loadWatchlists();
    _loaded = true;
    notifyListeners();
  }

  WatchlistModel? byId(String id) {
    for (final w in _watchlists) {
      if (w.id == id) return w;
    }
    return null;
  }

  Future<void> createWatchlist(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _watchlists.add(WatchlistModel(id: _uuid.v4(), name: trimmed));
    await _persist();
  }

  Future<void> renameWatchlist(String id, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;
    final w = byId(id);
    if (w == null) return;
    w.name = trimmed;
    await _persist();
  }

  Future<void> deleteWatchlist(String id) async {
    _watchlists.removeWhere((w) => w.id == id);
    await _persist();
  }

  Future<void> addStock(String watchlistId, String symbol) async {
    final w = byId(watchlistId);
    if (w == null) return;
    if (w.symbols.contains(symbol)) return;
    w.symbols.add(symbol);
    await _persist();
  }

  Future<void> removeStock(String watchlistId, String symbol) async {
    final w = byId(watchlistId);
    if (w == null) return;
    w.symbols.remove(symbol);
    await _persist();
  }

  Future<void> reorder(String watchlistId, int oldIndex, int newIndex) async {
    final w = byId(watchlistId);
    if (w == null) return;
    if (newIndex > oldIndex) newIndex -= 1;
    final symbol = w.symbols.removeAt(oldIndex);
    w.symbols.insert(newIndex, symbol);
    await _persist();
  }

  Future<void> _persist() async {
    notifyListeners();
    await _persistence.saveWatchlists(_watchlists);
  }
}
