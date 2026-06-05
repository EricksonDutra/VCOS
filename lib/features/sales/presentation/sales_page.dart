import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/date_formatting.dart';
import '../../../core/data/money.dart';
import '../../../core/data/sync_status.dart';
import '../../../core/models/sale.dart';
import '../../../core/state/vcos_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../shared/presentation/record_forms.dart';
import '../../shared/presentation/sync_status_icon.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VcosController>(
      builder: (context, controller, _) {
        final sales = controller.visibleSales;

        return _RecordListPage<Sale>(
          title: 'Vendas',
          description: 'Registre encomendas, pagamentos e produtos vendidos.',
          emptyText: 'Nenhuma venda ainda. Toque em Nova venda para comecar.',
          actionLabel: 'Nova venda',
          onAction: () => showSaleDialog(context),
          records: sales,
          itemBuilder: (sale) => _SaleTile(sale: sale),
        );
      },
    );
  }
}

class _SaleTile extends StatelessWidget {
  const _SaleTile({required this.sale});

  final Sale sale;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.shopping_bag_rounded,
              size: 44,
              color: AppColors.cherryPink,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sale.description,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    sale.customerName.isEmpty
                        ? 'Cliente nao informado'
                        : sale.customerName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Data: ${formatDate(sale.createdAt)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _SyncBadge(
                    value: formatMoney(sale.amount),
                    status: sale.syncStatus,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _RecordActions(
                    onEdit: () => showSaleDialog(context, sale: sale),
                    onDelete: () => _confirmDeleteSale(context, sale),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordActions extends StatelessWidget {
  const _RecordActions({
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        OutlinedButton.icon(
          key: const ValueKey('edit-record-button'),
          onPressed: onEdit,
          icon: const Icon(Icons.edit_rounded),
          label: const Text('Editar'),
        ),
        OutlinedButton.icon(
          key: const ValueKey('delete-record-button'),
          onPressed: onDelete,
          icon: const Icon(Icons.delete_rounded),
          label: const Text('Excluir'),
        ),
      ],
    );
  }
}

Future<void> _confirmDeleteSale(BuildContext context, Sale sale) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Excluir venda?'),
        content: Text('A venda "${sale.description}" sera removida da lista.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      );
    },
  );

  if (shouldDelete == true && context.mounted) {
    await context.read<VcosController>().deleteSale(sale);
  }
}

class _RecordListPage<T> extends StatelessWidget {
  const _RecordListPage({
    required this.title,
    required this.description,
    required this.emptyText,
    required this.actionLabel,
    required this.onAction,
    required this.records,
    required this.itemBuilder,
  });

  final String title;
  final String description;
  final String emptyText;
  final String actionLabel;
  final VoidCallback onAction;
  final List<T> records;
  final Widget Function(T record) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (records.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  emptyText,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            )
          else
            ...records.map(itemBuilder).expand(
                  (item) => [item, const SizedBox(height: AppSpacing.md)],
                ),
        ],
      ),
    );
  }
}

class _SyncBadge extends StatelessWidget {
  const _SyncBadge({
    required this.value,
    required this.status,
  });

  final String value;
  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        SyncStatusIcon(status: status),
      ],
    );
  }
}
