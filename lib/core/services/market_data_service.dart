import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/stock.dart';

/// The single source of truth for prices across the whole app.
///
/// Design notes:
/// - Every symbol gets its own [ValueNotifier<Quote>] and its own timer.
///   Widgets that need a live price bind directly to that notifier with a
///   `ValueListenableBuilder`, so a tick for RELIANCE only rebuilds the
///   RELIANCE row/cell — nothing else in the tree repaints.
/// - We deliberately do NOT put this behind a plain `ChangeNotifier` with
///   `notifyListeners()` on every tick: that would force a rebuild of every
///   widget watching the provider, which is exactly the "unnecessary
///   rebuild" the assignment warns against under load (50+ ticks/sec).
/// - Tick rate is configurable via [ticksPerSecondPerStock]. With 10 stocks
///   each ticking independently, setting this to 5.0 gives ~50 ticks/sec
///   system-wide, matching the stress scenario in the brief.
class MarketDataService {
  MarketDataService({double ticksPerSecondPerStock = 1.5})
      : _ticksPerSecondPerStock = ticksPerSecondPerStock {
    for (final s in kStockUniverse) {
      _quotes[s.symbol] = ValueNotifier<Quote>(
        Quote(
          ltpPaise: s.basePricePaise,
          prevClosePaise: s.basePricePaise,
          direction: TickDirection.none,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  final Map<String, ValueNotifier<Quote>> _quotes = {};
  final Map<String, Timer> _timers = {};
  final Random _rng = Random();
  double _ticksPerSecondPerStock;
  bool _running = false;

  double get ticksPerSecondPerStock => _ticksPerSecondPerStock;

  /// Read-only access to a symbol's live notifier. Bind with
  /// ValueListenableBuilder; do not mutate.
  ValueNotifier<Quote> quoteNotifier(String symbol) {
    final n = _quotes[symbol];
    assert(n != null, 'Unknown symbol: $symbol');
    return n!;
  }

  Quote currentQuote(String symbol) => quoteNotifier(symbol).value;

  void start() {
    if (_running) return;
    _running = true;
    for (final s in kStockUniverse) {
      _scheduleNext(s.symbol);
    }
  }

  void stop() {
    _running = false;
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();
  }

  /// Changes the feed rate live (e.g. from a debug settings screen) and
  /// restarts timers so the new rate takes effect immediately.
  void setTicksPerSecondPerStock(double rate) {
    _ticksPerSecondPerStock = rate.clamp(0.2, 20.0);
    if (_running) {
      stop();
      start();
    }
  }

  void _scheduleNext(String symbol) {
    if (!_running) return;
    final baseMs = (1000 / _ticksPerSecondPerStock).clamp(50, 5000).round();
    // Jitter +/-20% so all 10 symbols don't tick in lockstep, which is more
    // representative of a real feed and avoids one big simultaneous frame.
    final jitter = (baseMs * 0.2).round();
    final delayMs = baseMs + (_rng.nextInt(jitter * 2 + 1) - jitter);
    _timers[symbol] = Timer(Duration(milliseconds: max(20, delayMs)), () {
      _tick(symbol);
      _scheduleNext(symbol);
    });
  }

  void _tick(String symbol) {
    final notifier = _quotes[symbol]!;
    final prev = notifier.value;

    // Random walk: move by up to ~0.35% of the current price, in whole
    // paise, so downstream math never touches a double.
    final maxDeltaPaise = max(1, (prev.ltpPaise * 0.0035).round());
    final delta = _rng.nextInt(maxDeltaPaise * 2 + 1) - maxDeltaPaise;
    var newLtp = prev.ltpPaise + delta;
    if (newLtp < 100) newLtp = 100; // floor at ₹1.00, never negative/zero

    final direction = newLtp > prev.ltpPaise
        ? TickDirection.up
        : newLtp < prev.ltpPaise
            ? TickDirection.down
            : TickDirection.none;

    notifier.value = Quote(
      ltpPaise: newLtp,
      prevClosePaise: prev.prevClosePaise,
      direction: direction,
      updatedAt: DateTime.now(),
    );
  }

  void dispose() {
    stop();
    for (final n in _quotes.values) {
      n.dispose();
    }
  }
}
