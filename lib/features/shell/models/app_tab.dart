import 'package:flutter/material.dart';

class AppTab {
  const AppTab({
    required this.label,
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.page,
  });

  final String label;
  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final Widget page;
}
