import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool success;
  const StatusBadge({required this.status, required this.success});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (success ? AppTheme.success : AppTheme.danger).withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: success ? AppTheme.success : AppTheme.danger,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}