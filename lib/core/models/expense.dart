import 'dart:convert';

import '../data/sync_status.dart';

class Expense {
  const Expense({
    required this.id,
    required this.description,
    required this.category,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    this.remoteId,
    this.notes = '',
    this.photoPaths = const [],
    this.deletedAt,
  });

  final String id;
  final String? remoteId;
  final String description;
  final String category;
  final double amount;
  final String notes;
  final List<String> photoPaths;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final SyncStatus syncStatus;

  bool get isDeleted => deletedAt != null;

  Expense copyWith({
    String? remoteId,
    String? description,
    String? category,
    double? amount,
    String? notes,
    List<String>? photoPaths,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    SyncStatus? syncStatus,
  }) {
    return Expense(
      id: id,
      remoteId: remoteId ?? this.remoteId,
      description: description ?? this.description,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      photoPaths: photoPaths ?? this.photoPaths,
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
      'category': category,
      'amount': amount,
      'notes': notes,
      'photo_paths': jsonEncode(photoPaths),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'sync_status': syncStatus.name,
    };
  }

  static Expense fromMap(Map<String, Object?> map) {
    return Expense(
      id: map['id'] as String,
      remoteId: map['remote_id'] as String?,
      description: map['description'] as String,
      category: map['category'] as String? ?? 'Materiais',
      amount: (map['amount'] as num).toDouble(),
      notes: map['notes'] as String? ?? '',
      photoPaths: _photoPathsFromMap(map['photo_paths']),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      deletedAt: map['deleted_at'] == null
          ? null
          : DateTime.parse(map['deleted_at'] as String),
      syncStatus: SyncStatus.fromName(map['sync_status'] as String?),
    );
  }

  static List<String> _photoPathsFromMap(Object? value) {
    if (value == null) return const [];
    try {
      final decoded = jsonDecode(value as String);
      if (decoded is! List) return const [];
      return decoded.whereType<String>().toList();
    } on FormatException {
      return const [];
    } on TypeError {
      return const [];
    }
  }
}
