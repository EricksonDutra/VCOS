import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/money.dart';
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
        final expenseShare =
            summary.salesTotal == 0 ? 0.0 : (summary.expensesTotal / summary.salesTotal).clamp(0.0, 1.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Visualize resultados, gr\u00e1ficos e relat\u00f3rios para compartilhar.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              _ReportRow(label: 'Entradas', value: formatMoney(summary.salesTotal)),
              _ReportRow(
                label: 'Sa\u00eddas',
                value: formatMoney(summary.expensesTotal),
              ),
              _ReportRow(label: 'Saldo', value: formatMoney(summary.balance)),
              const SizedBox(height: AppSpacing.lg),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Peso dos gastos',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      LinearProgressIndicator(
                        value: expenseShare,
                        minHeight: 18,
                        color: AppColors.cherryPink,
                        backgroundColor: AppColors.sageGreen,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        summary.salesTotal == 0
                            ? 'Registre vendas para calcular a proporcao.'
                            : 'Gastos representam ${(expenseShare * 100).round()}% das vendas.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
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
