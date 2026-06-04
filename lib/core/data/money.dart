import 'package:intl/intl.dart';

final _moneyFormatter = NumberFormat.currency(
  locale: 'pt_BR',
  symbol: 'R\$',
);

String formatMoney(double value) => _moneyFormatter.format(value);

double parseMoney(String value) {
  final normalized = value
      .replaceAll('R\$', '')
      .replaceAll('.', '')
      .replaceAll(',', '.')
      .trim();
  return double.tryParse(normalized) ?? 0;
}
