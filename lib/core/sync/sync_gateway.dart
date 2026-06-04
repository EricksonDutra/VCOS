import '../models/expense.dart';
import '../models/sale.dart';

class SyncResult {
  const SyncResult({
    required this.success,
    this.message = '',
  });

  final bool success;
  final String message;
}

abstract class SyncGateway {
  Future<SyncResult> pushChanges({
    required List<Sale> sales,
    required List<Expense> expenses,
  });
}

class PendingApiSyncGateway implements SyncGateway {
  const PendingApiSyncGateway();

  @override
  Future<SyncResult> pushChanges({
    required List<Sale> sales,
    required List<Expense> expenses,
  }) async {
    return const SyncResult(
      success: false,
      message: 'API ainda nao configurada. Dados mantidos localmente.',
    );
  }
}
