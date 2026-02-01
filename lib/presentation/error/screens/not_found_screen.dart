import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';

/// 404 / Not Found screen - shown when route doesn't exist or error occurs
class NotFoundScreen extends StatelessWidget {
  final String? path;
  final Exception? error;

  const NotFoundScreen({
    super.key,
    this.path,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 24),
                Text(
                  'Page Not Found',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  path != null
                      ? 'The page "$path" could not be found.'
                      : 'The requested page could not be found.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                if (error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.dashboard),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Go to Home'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.dashboard),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
