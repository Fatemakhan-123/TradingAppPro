import 'package:flutter/material.dart';

import '../core/models/stock.dart';
import '../core/money.dart';

class FlashPriceCell extends StatefulWidget {
  const FlashPriceCell({
    super.key,
    required this.quoteListenable,
    this.dense = false,
  });

  final ValueNotifier<Quote> quoteListenable;
  final bool dense;

  @override
  State<FlashPriceCell> createState() => _FlashPriceCellState();
}

class _FlashPriceCellState extends State<FlashPriceCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flashController;
  Color _flashColor = Colors.transparent;
  TickDirection _lastDirection = TickDirection.none;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    widget.quoteListenable.addListener(_onTick);
  }

  void _onTick() {
    final direction = widget.quoteListenable.value.direction;
    if (direction != TickDirection.none && direction != _lastDirection) {
      _flashColor = direction == TickDirection.up
          ? Colors.green.withOpacity(0.35)
          : Colors.red.withOpacity(0.35);
      _flashController.forward(from: 0);
    }
    _lastDirection = direction;
  }

  @override
  void dispose() {
    widget.quoteListenable.removeListener(_onTick);
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Quote>(
      valueListenable: widget.quoteListenable,
      builder: (context, quote, _) {
        final up = quote.changePaise >= 0;
        final changeColor = up ? Colors.green.shade700 : Colors.red.shade700;
        final ltp = Money(quote.ltpPaise);
        final change = Money(quote.changePaise);

        return AnimatedBuilder(
          animation: _flashController,
          builder: (context, child) {
            final t = 1 - _flashController.value; // fade out
            final bg = Color.lerp(Colors.transparent, _flashColor, t)!;
            return DecoratedBox(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: child,
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: widget.dense ? 2 : 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ltp.formatted,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: widget.dense ? 14 : 16,
                  ),
                ),
                Text(
                  '${up ? '+' : ''}${change.formattedPlain} (${up ? '+' : ''}${quote.changePercent.toStringAsFixed(2)}%)',
                  style: TextStyle(
                    color: changeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
