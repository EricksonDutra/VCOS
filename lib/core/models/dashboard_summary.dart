import 'expense.dart';
import 'sale.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.salesTotal,
    required this.expensesTotal,
    required this.pendingSyncCount,
    required this.salesCount,
    required this.expensesCount,
  });

  final double salesTotal;
  final double expensesTotal;
  final int pendingSyncCount;
  final int salesCount;
  final int expensesCount;

  double get balance => salesTotal - expensesTotal;

  factory DashboardSummary.fromRecords({
    required List<Sale> sales,
    required List<Expense> expenses,
    required int pendingSyncCount,
  }) {
    final activeSales = sales.where((sale) => !sale.isDeleted).toList();
    final activeExpenses =
        expenses.where((expense) => !expense.isDeleted).toList();

    return DashboardSummary(
      salesTotal: activeSales.fold(0, (total, sale) => total + sale.amount),
      expensesTotal: activeExpenses.fold(
        0,
        (total, expense) => total + expense.amount,
      ),
      pendingSyncCount: pendingSyncCount,
      salesCount: activeSales.length,
      expensesCount: activeExpenses.length,
    );
  }
}
