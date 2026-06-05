class AppSettings {
  const AppSettings({
    required this.studioName,
    required this.ownerName,
    required this.phone,
    required this.autoSyncEnabled,
    required this.highContrastEnabled,
    this.fontScale = 1.0,
    this.reduceMotionEnabled = false,
    this.largeTouchTargetsEnabled = true,
    required this.updatedAt,
  });

  factory AppSettings.defaults() {
    return AppSettings(
      studioName: 'VCOS Retalhos',
      ownerName: '',
      phone: '',
      autoSyncEnabled: true,
      highContrastEnabled: false,
      fontScale: 1.0,
      reduceMotionEnabled: false,
      largeTouchTargetsEnabled: true,
      updatedAt: DateTime.now(),
    );
  }

  final String studioName;
  final String ownerName;
  final String phone;
  final bool autoSyncEnabled;
  final bool highContrastEnabled;
  final double fontScale;
  final bool reduceMotionEnabled;
  final bool largeTouchTargetsEnabled;
  final DateTime updatedAt;

  AppSettings copyWith({
    String? studioName,
    String? ownerName,
    String? phone,
    bool? autoSyncEnabled,
    bool? highContrastEnabled,
    double? fontScale,
    bool? reduceMotionEnabled,
    bool? largeTouchTargetsEnabled,
    DateTime? updatedAt,
  }) {
    return AppSettings(
      studioName: studioName ?? this.studioName,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      highContrastEnabled: highContrastEnabled ?? this.highContrastEnabled,
      fontScale: fontScale ?? this.fontScale,
      reduceMotionEnabled: reduceMotionEnabled ?? this.reduceMotionEnabled,
      largeTouchTargetsEnabled:
          largeTouchTargetsEnabled ?? this.largeTouchTargetsEnabled,
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
      'font_scale': fontScale,
      'reduce_motion_enabled': reduceMotionEnabled ? 1 : 0,
      'large_touch_targets_enabled': largeTouchTargetsEnabled ? 1 : 0,
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
      fontScale: _doubleFromMap(map['font_scale'], fallback: 1.0),
      reduceMotionEnabled: _boolFromMap(map['reduce_motion_enabled']),
      largeTouchTargetsEnabled: _boolFromMap(
        map['large_touch_targets_enabled'],
        fallback: true,
      ),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  static bool _boolFromMap(Object? value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    return fallback;
  }

  static double _doubleFromMap(Object? value, {required double fallback}) {
    if (value is num) return value.toDouble();
    return fallback;
  }
}
