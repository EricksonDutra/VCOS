import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vcos_app/app/vcos_app.dart';
import 'package:vcos_app/features/shell/models/app_tabs.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Finder bottomNavIcon(IconData icon) {
    return find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.byIcon(icon),
    );
  }

  testWidgets('user can navigate through every main app area', (tester) async {
    await tester.pumpWidget(const VcosApp(useGoogleFonts: false));
    await tester.pumpAndSettle();

    expect(find.text('VCOS'), findsOneWidget);
    expect(find.text('Ver resumo'), findsWidgets);

    for (final tab in appTabs) {
      await tester.tap(bottomNavIcon(tab.icon));
      await tester.pumpAndSettle();

      expect(find.text(tab.title), findsWidgets);
      expect(find.text(tab.description), findsOneWidget);
      expect(find.text(tab.actionLabel), findsWidgets);
    }
  });
}
