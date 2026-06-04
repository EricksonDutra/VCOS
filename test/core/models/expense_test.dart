import 'package:flutter_test/flutter_test.dart';
import 'package:vcos_app/core/data/sync_status.dart';
import 'package:vcos_app/core/models/expense.dart';

void main() {
  test('keeps expense photo paths when mapping to and from storage', () {
    final now = DateTime(2026, 6, 3, 10);
    final expense = Expense(
      id: 'expense-1',
      description: 'Tecido',
      category: 'Materiais',
      amount: 30,
      notes: 'Algodao',
      photoPaths: const [
        r'C:\app\expense_photos\foto-1.jpg',
        r'C:\app\expense_photos\foto-2.jpg',
      ],
      createdAt: now,
      updatedAt: now,
      syncStatus: SyncStatus.pending,
    );

    final restored = Expense.fromMap(expense.toMap());

    expect(restored.photoPaths, expense.photoPaths);
  });
}
