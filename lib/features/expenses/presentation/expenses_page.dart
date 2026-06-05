import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/date_formatting.dart';
import '../../../core/data/money.dart';
import '../../../core/models/expense.dart';
import '../../../core/state/vcos_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../shared/presentation/record_forms.dart';
import '../../shared/presentation/sync_status_icon.dart';
import 'expense_detail_page.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VcosController>(
      builder: (context, controller, _) {
        final expenses = controller.visibleExpenses;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Organize materiais, despesas e custos do dia a dia.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (expenses.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Nenhum gasto ainda. Registre materiais, embalagens e outras despesas.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                )
              else
                ...expenses
                    .map((expense) => _ExpenseTile(expense: expense))
                    .expand(
                      (item) => [item, const SizedBox(height: AppSpacing.md)],
                    ),
            ],
          ),
        );
      },
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ExpenseDetailPage(expenseId: expense.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                size: 44,
                color: AppColors.honeyGold,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.description,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      expense.category,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Data: ${formatDate(expense.createdAt)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (expense.photoPaths.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${expense.photoPaths.length} foto(s)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: 4,
                      children: [
                        Text(
                          formatMoney(expense.amount),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SyncStatusIcon(status: expense.syncStatus),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        OutlinedButton.icon(
                          key: ValueKey('edit-expense-${expense.id}'),
                          onPressed: () => showExpenseDialog(
                            context,
                            expense: expense,
                          ),
                          icon: const Icon(Icons.edit_rounded),
                          label: const Text('Editar'),
                        ),
                        OutlinedButton.icon(
                          key: ValueKey('delete-expense-${expense.id}'),
                          onPressed: () => _confirmDeleteExpense(
                            context,
                            expense,
                          ),
                          icon: const Icon(Icons.delete_rounded),
                          label: const Text('Excluir'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _confirmDeleteExpense(
    BuildContext context, Expense expense) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Excluir gasto?'),
        content:
            Text('O gasto "${expense.description}" sera removido da lista.'),
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
    await context.read<VcosController>().deleteExpense(expense);
  }
}
