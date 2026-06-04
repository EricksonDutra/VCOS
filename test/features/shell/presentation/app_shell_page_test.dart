import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vcos_app/app/vcos_app.dart';
import 'package:vcos_app/core/data/date_formatting.dart';
import 'package:vcos_app/features/shell/models/app_tabs.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      const VcosApp(
        useGoogleFonts: false,
        showSplash: false,
        useLocalDatabase: false,
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder bottomNavIcon(IconData icon) {
    return find.descendant(
      of: find.byType(NavigationBar),
      matching: find.byIcon(icon),
    );
  }

  testWidgets('starts on the home tab with the VCOS app shell', (tester) async {
    await pumpApp(tester);

    expect(find.text('VCOS'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Ver resumo'), findsWidgets);
    expect(
      find.text(
        'Acompanhe os principais n\u00fameros do ateli\u00ea em um s\u00f3 lugar.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows the five main navigation tabs', (tester) async {
    await pumpApp(tester);

    for (final tab in appTabs) {
      expect(find.text(tab.label), findsWidgets);
    }
  });

  testWidgets('changes visible content and action when each tab is selected', (
    tester,
  ) async {
    await pumpApp(tester);

    for (final tab in appTabs) {
      await tester.tap(bottomNavIcon(tab.icon));
      await tester.pumpAndSettle();

      expect(find.text(tab.title), findsWidgets);
      expect(find.text(tab.actionLabel), findsWidgets);
    }
  });

  testWidgets('registers sales and expenses offline through the app', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(bottomNavIcon(Icons.shopping_bag_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nova venda').first);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Produto vendido'),
      'Rascunho errado',
    );
    await tester.ensureVisible(find.text('Cancelar'));
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nova venda').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextFormField, 'Produto vendido'));
    await tester.pumpAndSettle();
    expect(find.text('Rascunho errado'), findsNothing);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Produto vendido'),
      'Avental',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Cliente'), 'Maria');
    await tester.enterText(find.widgetWithText(TextFormField, 'Valor'), '85,00');
    await tester.ensureVisible(find.text('Salvar venda'));
    await tester.tap(find.text('Salvar venda'));
    await tester.pumpAndSettle();

    expect(find.text('Avental'), findsOneWidget);
    expect(find.text('Data: ${formatDate(DateTime.now())}'), findsWidgets);
    expect(find.text('pendente'), findsNothing);
    expect(find.byIcon(Icons.cloud_off_rounded), findsWidgets);

    await tester.tap(find.text('Editar').first);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Produto vendido'),
      'Avental floral',
    );
    await tester.ensureVisible(find.text('Atualizar venda'));
    await tester.tap(find.text('Atualizar venda'));
    await tester.pumpAndSettle();

    expect(find.text('Avental floral'), findsOneWidget);
    expect(find.text('Avental'), findsNothing);

    await tester.tap(find.text('Nova venda').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextFormField, 'Produto vendido'));
    await tester.pumpAndSettle();
    expect(find.text('Avental'), findsWidgets);
    await tester.ensureVisible(find.text('Cancelar'));
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    await tester.tap(bottomNavIcon(Icons.receipt_long_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Novo gasto').first);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Material ou despesa'),
      'Tecido',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Categoria'), 'Materiais');
    await tester.enterText(find.widgetWithText(TextFormField, 'Valor'), '30,00');
    await tester.ensureVisible(find.text('Salvar gasto'));
    await tester.tap(find.text('Salvar gasto'));
    await tester.pumpAndSettle();

    expect(find.text('Tecido'), findsOneWidget);
    expect(find.text('Materiais'), findsOneWidget);

    await tester.tap(find.text('Tecido'));
    await tester.pumpAndSettle();
    expect(find.text('Detalhes do gasto'), findsOneWidget);
    expect(find.text('Nenhuma foto registrada.'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Novo gasto').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextFormField, 'Material ou despesa'));
    await tester.pumpAndSettle();
    expect(find.text('Tecido'), findsWidgets);
    await tester.ensureVisible(find.text('Cancelar'));
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    final deleteExpenseButton = find.byWidgetPredicate(
      (widget) =>
          widget.key is ValueKey<String> &&
          (widget.key! as ValueKey<String>).value.startsWith('delete-expense-'),
    );
    await tester.ensureVisible(deleteExpenseButton);
    await tester.tap(deleteExpenseButton);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
    await tester.pumpAndSettle();

    expect(find.text('Tecido'), findsNothing);
  });

  testWidgets('saves settings locally', (tester) async {
    await pumpApp(tester);

    await tester.tap(bottomNavIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Nome do ateli\u00ea'),
      'VCOS Casa',
    );
    await tester.ensureVisible(find.text('Salvar configura\u00e7\u00f5es'));
    await tester.tap(find.text('Salvar configura\u00e7\u00f5es'));
    await tester.pumpAndSettle();

    expect(find.text('VCOS Casa'), findsOneWidget);
  });
}
