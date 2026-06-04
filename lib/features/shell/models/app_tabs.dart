import 'package:flutter/material.dart';

import '../../expenses/presentation/expenses_page.dart';
import '../../home/presentation/home_page.dart';
import '../../reports/presentation/reports_page.dart';
import '../../sales/presentation/sales_page.dart';
import '../../settings/presentation/settings_page.dart';
import 'app_tab.dart';

const appTabs = [
  AppTab(
    label: 'In\u00edcio',
    icon: Icons.home_rounded,
    title: 'In\u00edcio',
    description: 'Acompanhe os principais n\u00fameros do ateli\u00ea em um s\u00f3 lugar.',
    actionLabel: 'Ver resumo',
    page: HomePage(),
  ),
  AppTab(
    label: 'Vendas',
    icon: Icons.shopping_bag_rounded,
    title: 'Vendas',
    description: 'Registre encomendas, pagamentos e produtos vendidos.',
    actionLabel: 'Nova venda',
    page: SalesPage(),
  ),
  AppTab(
    label: 'Gastos',
    icon: Icons.receipt_long_rounded,
    title: 'Gastos',
    description: 'Organize materiais, despesas e custos do dia a dia.',
    actionLabel: 'Novo gasto',
    page: ExpensesPage(),
  ),
  AppTab(
    label: 'Rel.',
    icon: Icons.bar_chart_rounded,
    title: 'Relat\u00f3rios',
    description: 'Visualize resultados, gr\u00e1ficos e relat\u00f3rios para compartilhar.',
    actionLabel: 'Abrir relat\u00f3rios',
    page: ReportsPage(),
  ),
  AppTab(
    label: 'Config',
    icon: Icons.settings_rounded,
    title: 'Configura\u00e7\u00f5es',
    description: 'Ajuste prefer\u00eancias, dados do ateli\u00ea e op\u00e7\u00f5es de acessibilidade.',
    actionLabel: 'Editar ajustes',
    page: SettingsPage(),
  ),
];
