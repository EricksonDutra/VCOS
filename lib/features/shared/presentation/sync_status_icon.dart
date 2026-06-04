import 'package:flutter/material.dart';

import '../../../core/data/sync_status.dart';
import '../../../core/theme/app_colors.dart';

class SyncStatusIcon extends StatelessWidget {
  const SyncStatusIcon({
    required this.status,
    super.key,
  });

  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    final synced = status == SyncStatus.synced;
    final label = synced ? 'Sincronizado' : 'Aguardando sincronizacao';

    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        child: Icon(
          synced ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
          size: 34,
          color: synced ? AppColors.tealGreen : AppColors.grapePurple,
        ),
      ),
    );
  }
}
