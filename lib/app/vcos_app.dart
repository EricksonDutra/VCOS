import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/data/local_database.dart';
import '../core/data/memory_vcos_repository.dart';
import '../core/data/sqflite_vcos_repository.dart';
import '../core/data/vcos_repository.dart';
import '../core/state/vcos_controller.dart';
import '../core/sync/sync_gateway.dart';
import '../core/theme/app_theme.dart';
import '../features/shell/presentation/app_shell_page.dart';

class VcosApp extends StatelessWidget {
  const VcosApp({
    this.useGoogleFonts = true,
    this.showSplash = true,
    this.useLocalDatabase = true,
    this.repository,
    this.syncGateway,
    super.key,
  });

  final bool useGoogleFonts;
  final bool showSplash;
  final bool useLocalDatabase;
  final VcosRepository? repository;
  final SyncGateway? syncGateway;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final appRepository = repository ??
            (useLocalDatabase
                ? SqfliteVcosRepository(LocalDatabase())
                : MemoryVcosRepository());
        final appSyncGateway = syncGateway ??
            (useLocalDatabase
                ? ApiSyncGateway()
                : const PendingApiSyncGateway());
        return VcosController(
          repository: appRepository,
          syncGateway: appSyncGateway,
        )..load();
      },
      child: Consumer<VcosController>(
        builder: (context, controller, _) {
          final settings = controller.settings;
          return MaterialApp(
            title: 'VCOS',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.create(
              useGoogleFonts: useGoogleFonts,
              highContrast: settings.highContrastEnabled,
              largeTouchTargets: settings.largeTouchTargetsEnabled,
            ),
            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);
              return MediaQuery(
                data: mediaQuery.copyWith(
                  disableAnimations: mediaQuery.disableAnimations ||
                      settings.reduceMotionEnabled,
                  textScaler: TextScaler.linear(settings.fontScale),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: AppShellPage(showSplash: showSplash),
          );
        },
      ),
    );
  }
}
