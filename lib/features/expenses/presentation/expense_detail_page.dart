import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/date_formatting.dart';
import '../../../core/data/money.dart';
import '../../../core/data/sync_status.dart';
import '../../../core/models/expense.dart';
import '../../../core/state/vcos_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../shared/presentation/record_forms.dart';

class ExpenseDetailPage extends StatelessWidget {
  const ExpenseDetailPage({
    required this.expenseId,
    super.key,
  });

  final String expenseId;

  @override
  Widget build(BuildContext context) {
    return Consumer<VcosController>(
      builder: (context, controller, _) {
        final expense = _expenseById(controller.expenses, expenseId);
        if (expense == null || expense.isDeleted) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detalhes do gasto')),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Este gasto nao esta mais disponivel.'),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Detalhes do gasto')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ExpenseHeader(expense: expense),
                const SizedBox(height: AppSpacing.lg),
                _DetailSection(
                  title: 'Informacoes',
                  children: [
                    _DetailRow(label: 'Categoria', value: expense.category),
                    _DetailRow(
                      label: 'Data',
                      value: formatDate(expense.createdAt),
                    ),
                    _DetailRow(
                      label: 'Valor',
                      value: formatMoney(expense.amount),
                    ),
                    _DetailRow(
                      label: 'Sincronizacao',
                      value: expense.syncStatus == SyncStatus.synced
                          ? 'Sincronizado'
                          : 'Pendente',
                    ),
                    if (expense.notes.trim().isNotEmpty)
                      _DetailRow(label: 'Observacoes', value: expense.notes),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _DetailSection(
                  title: 'Fotos',
                  children: [
                    if (expense.photoPaths.isEmpty)
                      Text(
                        'Nenhuma foto registrada.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      )
                    else
                      _PhotoGrid(photoPaths: expense.photoPaths),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    FilledButton.icon(
                      onPressed: () => showExpenseDialog(
                        context,
                        expense: expense,
                      ),
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Editar gasto'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _confirmDeleteExpense(context, expense),
                      icon: const Icon(Icons.delete_rounded),
                      label: const Text('Excluir gasto'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Expense? _expenseById(List<Expense> expenses, String id) {
    for (final expense in expenses) {
      if (expense.id == id) return expense;
    }
    return null;
  }
}

class _ExpenseHeader extends StatelessWidget {
  const _ExpenseHeader({required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.receipt_long_rounded,
              size: 48,
              color: AppColors.honeyGold,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${expense.photoPaths.length} foto(s) anexada(s)',
                    style: Theme.of(context).textTheme.bodyLarge,
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

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            ...children.expand(
              (child) => [child, const SizedBox(height: AppSpacing.sm)],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 2),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({required this.photoPaths});

  final List<String> photoPaths;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
      ),
      itemCount: photoPaths.length,
      itemBuilder: (context, index) {
        final path = photoPaths[index];
        return InkWell(
          onTap: () => _showPhoto(context, path),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(path),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.linen,
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image_rounded, size: 40),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPhoto(BuildContext context, String path) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Image.file(
                    File(path),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Icon(Icons.broken_image_rounded, size: 56),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Fechar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<void> _confirmDeleteExpense(BuildContext context, Expense expense) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Excluir gasto?'),
        content: Text('O gasto "${expense.description}" sera removido da lista.'),
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
    if (context.mounted) Navigator.of(context).pop();
  }
}
