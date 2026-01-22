import 'package:flutter/material.dart';
import '../../../core/widgets/error_widget.dart' as core;

/// Error view wrapper
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return core.ErrorDisplayWidget(
      message: message,
      onRetry: onRetry,
    );
  }
}

