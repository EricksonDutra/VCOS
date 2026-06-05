import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/date_formatting.dart';
import '../state/vcos_controller.dart';

class MonthFilterButton extends StatelessWidget {
  const MonthFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VcosController>();

    return Semantics(
      label: 'Filtrar mes ${formatMonth(controller.selectedMonth)}',
      button: true,
      child: TextButton.icon(
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: controller.selectedMonth,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            controller.setSelectedMonth(picked);
          }
        },
        icon: const Icon(Icons.calendar_month_rounded, size: 24),
        label: Text(formatMonth(controller.selectedMonth)),
      ),
    );
  }
}
