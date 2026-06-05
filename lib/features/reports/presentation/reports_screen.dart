import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/month_filter_button.dart';
import '../../../core/widgets/vcos_logo.dart';
import 'reports_page.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 18,
        title: const Row(
          children: [
            VcosLogo(size: 42),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Relatórios',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: const [
          MonthFilterButton(),
          SizedBox(width: 8),
        ],
      ),
      body: const DecoratedBox(
        decoration: BoxDecoration(color: AppColors.creamBackground),
        child: SafeArea(child: ReportsPage()),
      ),
    );
  }
}
