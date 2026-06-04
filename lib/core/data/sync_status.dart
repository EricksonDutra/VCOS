enum SyncStatus {
  synced,
  pending,
  failed;

  static SyncStatus fromName(String? name) {
    return SyncStatus.values.firstWhere(
      (status) => status.name == name,
      orElse: () => SyncStatus.pending,
    );
  }
}
