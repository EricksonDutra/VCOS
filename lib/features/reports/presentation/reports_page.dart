import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/date_formatting.dart';
import '../../../core/data/money.dart';
import '../../../core/models/expense.dart';
import '../../../core/state/vcos_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VcosController>(
      builder: (context, controller, _) {
        final summary = controller.summary;
        final sales = controller.visibleSales;
        final expenses = controller.visibleExpenses;
        final categoryTotals = _expenseTotalsByCategory(expenses);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Relat\u00f3rio de ${formatMonth(controller.selectedMonth)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              _ReportRow(
                label: 'Entradas',
                value: formatMoney(summary.salesTotal),
              ),
              _ReportRow(
                label: 'Sa\u00eddas',
                value: formatMoney(summary.expensesTotal),
              ),
              _ReportRow(label: 'Saldo', value: formatMoney(summary.balance)),
              const SizedBox(height: AppSpacing.lg),
              _ChartCard(
                title: 'Movimento do m\u00eas',
                child: _MonthlyBarChart(
                  salesTotal: summary.salesTotal,
                  expensesTotal: summary.expensesTotal,
                  balance: summary.balance,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _ChartCard(
                title: 'Vendas x gastos',
                child: _SalesExpensePieChart(
                  salesTotal: summary.salesTotal,
                  expensesTotal: summary.expensesTotal,
                ),
              ),
              if (categoryTotals.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                _ChartCard(
                  title: 'Gastos por categoria',
                  child: _ExpenseCategoryList(categoryTotals: categoryTotals),
                ),
              ],
              if (sales.isEmpty && expenses.isEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Sem registros neste m\u00eas. Use o filtro no topo para ver outro per\u00edodo.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.lg),
            child,
          ],
        ),
      ),
    );
  }
}

class _MonthlyBarChart extends StatelessWidget {
  const _MonthlyBarChart({
    required this.salesTotal,
    required this.expensesTotal,
    required this.balance,
  });

  final double salesTotal;
  final double expensesTotal;
  final double balance;

  @override
  Widget build(BuildContext context) {
    final maxValue = [
      salesTotal.abs(),
      expensesTotal.abs(),
      balance.abs(),
      1.0,
    ].reduce(math.max);

    return SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          minY: balance < 0 ? -maxValue * 1.15 : 0,
          maxY: maxValue * 1.25,
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.threadBrown.withValues(alpha: 0.12),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            _barGroup(0, salesTotal, AppColors.tealGreen),
            _barGroup(1, expensesTotal, AppColors.cherryPink),
            _barGroup(2, balance, AppColors.honeyGold),
          ],
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 54,
                getTitlesWidget: (value, _) => Text(
                  _compactMoney(value),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                      ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 46,
                getTitlesWidget: (value, _) {
                  final labels = ['Venda', 'Gasto', 'Saldo'];
                  final index = value.toInt();
                  if (index < 0 || index >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[index],
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double value, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          color: color,
          width: 34,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }
}

class _SalesExpensePieChart extends StatelessWidget {
  const _SalesExpensePieChart({
    required this.salesTotal,
    required this.expensesTotal,
  });

  final double salesTotal;
  final double expensesTotal;

  @override
  Widget build(BuildContext context) {
    final hasValues = salesTotal > 0 || expensesTotal > 0;
    final sections = hasValues
        ? [
            PieChartSectionData(
              value: salesTotal,
              color: AppColors.tealGreen,
              title: 'V',
              radius: 72,
              titleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                  ),
            ),
            PieChartSectionData(
              value: expensesTotal,
              color: AppColors.cherryPink,
              title: 'G',
              radius: 72,
              titleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                  ),
            ),
          ]
        : [
            PieChartSectionData(
              value: 1,
              color: AppColors.sageGreen,
              title: '',
              radius: 64,
            ),
          ];

    return Column(
      children: [
        SizedBox(
          height: 230,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 42,
              sectionsSpace: 4,
            ),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const _LegendRow(
          items: [
            _LegendItem('Vendas', AppColors.tealGreen),
            _LegendItem('Gastos', AppColors.cherryPink),
          ],
        ),
      ],
    );
  }
}

class _ExpenseCategoryList extends StatelessWidget {
  const _ExpenseCategoryList({required this.categoryTotals});

  final Map<String, double> categoryTotals;

  @override
  Widget build(BuildContext context) {
    final maxValue = categoryTotals.values.fold(1.0, math.max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: categoryTotals.entries.map((entry) {
        final progress = (entry.value / maxValue).clamp(0.0, 1.0);
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    formatMoney(entry.value),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 16,
                    color: AppColors.grapePurple,
                    backgroundColor: AppColors.sageGreen.withValues(alpha: 0.4),
                  );
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.items});

  final List<_LegendItem> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: items.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const SizedBox.square(dimension: 22),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(item.label, style: Theme.of(context).textTheme.bodyLarge),
          ],
        );
      }).toList(),
    );
  }
}

class _LegendItem {
  const _LegendItem(this.label, this.color);

  final String label;
  final Color color;
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.titleMedium),
            ),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}

Map<String, double> _expenseTotalsByCategory(Iterable<Expense> expenses) {
  final totals = <String, double>{};
  for (final expense in expenses) {
    totals.update(
      expense.category,
      (value) => value + expense.amount,
      ifAbsent: () => expense.amount,
    );
  }
  return totals;
}

String _compactMoney(double value) {
  if (value.abs() >= 1000) {
    return '${(value / 1000).toStringAsFixed(0)}k';
  }
  return value.toStringAsFixed(0);
}
