import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/money.dart';
import '../../../core/state/vcos_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../shared/presentation/record_forms.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VcosController>(
      builder: (context, controller, _) {
        final summary = controller.summary;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Acompanhe os principais n\u00fameros do ateli\u00ea em um s\u00f3 lugar.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (controller.isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                _SummaryCard(
                  label: 'Saldo do ateli\u00ea',
                  value: formatMoney(summary.balance),
                  icon: Icons.favorite_rounded,
                  color: AppColors.tealGreen,
                ),
                const SizedBox(height: AppSpacing.md),
                _SummaryCard(
                  label: 'Vendas registradas',
                  value: formatMoney(summary.salesTotal),
                  detail: '${summary.salesCount} vendas',
                  icon: Icons.shopping_bag_rounded,
                  color: AppColors.cherryPink,
                ),
                const SizedBox(height: AppSpacing.md),
                _SummaryCard(
                  label: 'Gastos registrados',
                  value: formatMoney(summary.expensesTotal),
                  detail: '${summary.expensesCount} gastos',
                  icon: Icons.receipt_long_rounded,
                  color: AppColors.honeyGold,
                ),
                const SizedBox(height: AppSpacing.md),
                _SyncStatusCard(
                  pendingCount: summary.pendingSyncCount,
                  isSyncing: controller.isSyncing,
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton.icon(
                  onPressed: () => showSaleDialog(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Registrar venda'),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () => showExpenseDialog(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Registrar gasto'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.detail,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 44, color: color),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(value,
                      style: Theme.of(context).textTheme.headlineMedium),
                  if (detail != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(detail!,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncStatusCard extends StatelessWidget {
  const _SyncStatusCard({
    required this.pendingCount,
    required this.isSyncing,
  });

  final int pendingCount;
  final bool isSyncing;

  @override
  Widget build(BuildContext context) {
    final status = pendingCount == 0
        ? 'Tudo salvo localmente'
        : '$pendingCount itens aguardando sincronizacao';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Icon(
              isSyncing ? Icons.sync_rounded : Icons.cloud_off_rounded,
              size: 42,
              color: AppColors.grapePurple,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(status, style: Theme.of(context).textTheme.bodyLarge),
            ),
          ],
        ),
      ),
    );
  }
}
