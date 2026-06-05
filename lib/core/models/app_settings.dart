class AppSettings {
  const AppSettings({
    required this.studioName,
    required this.ownerName,
    required this.phone,
    required this.autoSyncEnabled,
    required this.highContrastEnabled,
    required this.updatedAt,
  });

  factory AppSettings.defaults() {
    return AppSettings(
      studioName: 'VCOS Retalhos',
      ownerName: '',
      phone: '',
      autoSyncEnabled: true,
      highContrastEnabled: false,
      updatedAt: DateTime.now(),
    );
  }

  final String studioName;
  final String ownerName;
  final String phone;
  final bool autoSyncEnabled;
  final bool highContrastEnabled;
  final DateTime updatedAt;

  AppSettings copyWith({
    String? studioName,
    String? ownerName,
    String? phone,
    bool? autoSyncEnabled,
    bool? highContrastEnabled,
    DateTime? updatedAt,
  }) {
    return AppSettings(
      studioName: studioName ?? this.studioName,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      highContrastEnabled: highContrastEnabled ?? this.highContrastEnabled,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': 1,
      'studio_name': studioName,
      'owner_name': ownerName,
      'phone': phone,
      'auto_sync_enabled': autoSyncEnabled ? 1 : 0,
      'high_contrast_enabled': highContrastEnabled ? 1 : 0,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static AppSettings fromMap(Map<String, Object?> map) {
    return AppSettings(
      studioName: map['studio_name'] as String? ?? 'VCOS Retalhos',
      ownerName: map['owner_name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      autoSyncEnabled: _boolFromMap(map['auto_sync_enabled'], fallback: true),
      highContrastEnabled: _boolFromMap(map['high_contrast_enabled']),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  static bool _boolFromMap(Object? value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    return fallback;
  }
}
