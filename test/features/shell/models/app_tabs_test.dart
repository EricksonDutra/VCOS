import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vcos_app/features/expenses/presentation/expenses_page.dart';
import 'package:vcos_app/features/home/presentation/home_page.dart';
import 'package:vcos_app/features/reports/presentation/reports_page.dart';
import 'package:vcos_app/features/sales/presentation/sales_page.dart';
import 'package:vcos_app/features/settings/presentation/settings_page.dart';
import 'package:vcos_app/features/shell/models/app_tabs.dart';

void main() {
  group('appTabs', () {
    test('defines the five main VCOS areas in order', () {
      expect(appTabs.map((tab) => tab.label), [
        'In\u00edcio',
        'Vendas',
        'Gastos',
        'Rel.',
        'Config',
      ]);
    });

    test('keeps each tab configured with content and actions', () {
      for (final tab in appTabs) {
        expect(tab.label, isNotEmpty);
        expect(tab.title, isNotEmpty);
        expect(tab.description, isNotEmpty);
        expect(tab.actionLabel, isNotEmpty);
      }
    });

    test('uses unique labels and action labels', () {
      expect(
          appTabs.map((tab) => tab.label).toSet(), hasLength(appTabs.length));
      expect(
        appTabs.map((tab) => tab.actionLabel).toSet(),
        hasLength(appTabs.length),
      );
    });

    test('maps each navigation item to its feature page', () {
      expect(appTabs[0].icon, Icons.home_rounded);
      expect(appTabs[0].page, isA<HomePage>());
      expect(appTabs[1].icon, Icons.shopping_bag_rounded);
      expect(appTabs[1].page, isA<SalesPage>());
      expect(appTabs[2].icon, Icons.receipt_long_rounded);
      expect(appTabs[2].page, isA<ExpensesPage>());
      expect(appTabs[3].icon, Icons.bar_chart_rounded);
      expect(appTabs[3].page, isA<ReportsPage>());
      expect(appTabs[4].icon, Icons.settings_rounded);
      expect(appTabs[4].page, isA<SettingsPage>());
    });
  });
}
