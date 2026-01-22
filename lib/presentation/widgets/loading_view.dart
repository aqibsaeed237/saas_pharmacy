import 'package:flutter/material.dart';
import 'loading_widget.dart';

/// Loading view wrapper
class LoadingView extends StatelessWidget {
  final String? message;
  final Widget? child;

  const LoadingView({
    super.key,
    this.message,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return Stack(
        children: [
          child!,
          Container(
            color: Colors.black.withOpacity(0.3),
            child: LoadingWidget(message: message),
          ),
        ],
      );
    }
    return LoadingWidget(message: message);
  }
}

