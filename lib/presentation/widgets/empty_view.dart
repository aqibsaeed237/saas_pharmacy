import 'package:flutter/material.dart';
import '../../../core/widgets/empty_state_widget.dart';

/// Empty view wrapper
class EmptyView extends StatelessWidget {
  final String message;
  final IconData icon;
  final Widget? action;

  const EmptyView({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      message: message,
      icon: icon,
      action: action,
    );
  }
}

