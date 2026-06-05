String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String formatMonth(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  return '$month/${date.year}';
}

DateTime dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

DateTime monthOnly(DateTime date) {
  return DateTime(date.year, date.month);
}

DateTime addMonths(DateTime month, int amount) {
  return DateTime(month.year, month.month + amount);
}

bool isSameMonth(DateTime date, DateTime month) {
  return date.year == month.year && date.month == month.month;
}
