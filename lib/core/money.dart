import 'package:intl/intl.dart';

/// All money in the app is stored as an integer number of paise
/// (1 rupee = 100 paise). This avoids the floating point drift you'd get
/// from doing `qty * price` in doubles, which the assignment explicitly
/// calls out ("math is precise, no floating-point drift visible").
class Money {

  final int paise;
  const Money(this.paise);

  factory Money.fromRupees(double rupees) => Money((rupees * 100).round());

  static const zero = Money(0);

  double get rupees => paise / 100.0;

  Money operator +(Money other) => Money(paise + other.paise);
  Money operator -(Money other) => Money(paise - other.paise);
  Money operator *(int qty) => Money(paise * qty);

  bool operator <(Money other) => paise < other.paise;
  bool operator <=(Money other) => paise <= other.paise;
  bool operator >(Money other) => paise > other.paise;
  bool operator >=(Money other) => paise >= other.paise;

  bool get isNegative => paise < 0;

  static final NumberFormat _fmt = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  String get formatted => _fmt.format(rupees);

  /// Formats without the currency symbol, e.g. for "+1.24%" style deltas.
  String get formattedPlain => rupees.toStringAsFixed(2);

  @override
  String toString() => formatted;
}

/// Computes percentage change as a double *only* for display purposes.
/// The underlying comparison/arithmetic that money depends on always stays
/// in integer paise.
double percentChange(int fromPaise, int toPaise) {
  if (fromPaise == 0) return 0;
  return ((toPaise - fromPaise) / fromPaise) * 100;
}
