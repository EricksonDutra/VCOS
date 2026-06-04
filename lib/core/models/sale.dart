import '../data/sync_status.dart';

class Sale {
  const Sale({
    required this.id,
    required this.description,
    required this.customerName,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    this.remoteId,
    this.notes = '',
    this.deletedAt,
  });

  final String id;
  final String? remoteId;
  final String description;
  final String customerName;
  final double amount;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final SyncStatus syncStatus;

  bool get isDeleted => deletedAt != null;

  Sale copyWith({
    String? remoteId,
    String? description,
    String? customerName,
    double? amount,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    SyncStatus? syncStatus,
  }) {
    return Sale(
      id: id,
      remoteId: remoteId ?? this.remoteId,
      description: description ?? this.description,
      customerName: customerName ?? this.customerName,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'remote_id': remoteId,
      'description': description,
      'customer_name': customerName,
      'amount': amount,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'sync_status': syncStatus.name,
    };
  }

  static Sale fromMap(Map<String, Object?> map) {
    return Sale(
      id: map['id'] as String,
      remoteId: map['remote_id'] as String?,
      description: map['description'] as String,
      customerName: map['customer_name'] as String? ?? '',
      amount: (map['amount'] as num).toDouble(),
      notes: map['notes'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      deletedAt: map['deleted_at'] == null
          ? null
          : DateTime.parse(map['deleted_at'] as String),
      syncStatus: SyncStatus.fromName(map['sync_status'] as String?),
    );
  }
}
