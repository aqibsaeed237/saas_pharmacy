import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';

/// Widget to handle double tap to exit
class ExitConfirmation extends StatefulWidget {
  final Widget child;

  const ExitConfirmation({super.key, required this.child});

  @override
  State<ExitConfirmation> createState() => _ExitConfirmationState();
}

class _ExitConfirmationState extends State<ExitConfirmation> {
  DateTime? _lastBackPressed;

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    
    // If back button is pressed within 2 seconds, show exit dialog
    if (_lastBackPressed == null || 
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.exitMessage ?? 'Press back again to exit'),
          duration: const Duration(seconds: 2),
        ),
      );
      return false;
    }

    // Show confirmation dialog
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.exitApp ?? 'Exit App'),
        content: Text(AppLocalizations.of(context)?.exitConfirmation ?? 'Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)?.exit ?? 'Exit'),
          ),
        ],
      ),
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // Wrap child with PopScope that handles back button
    // The actual route checking will be done in onPopInvoked
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          // Check if we can navigate back (non-root route)
          final router = GoRouter.of(context);
          final canPop = router.canPop();
          
          if (canPop) {
            // Normal back navigation
            router.pop();
            return;
          }

          // Root route - show exit confirmation
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            // Exit app
            SystemNavigator.pop();
          }
        }
      },
      child: widget.child,
    );
  }
}
