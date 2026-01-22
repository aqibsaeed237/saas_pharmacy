import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_enums.dart';
import '../../widgets/app_button.dart';

/// Subscription screen
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  // Mock data
  final Map<String, dynamic> mockSubscription = const {
    'plan': 'Professional',
    'status': SubscriptionStatus.active,
    'expiryDate': '2024-12-31',
    'price': 99.99,
    'features': [
      'Unlimited products',
      'Unlimited staff',
      'Advanced reports',
      'Priority support',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final subscription = mockSubscription;
    final status = subscription['status'] as SubscriptionStatus;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current plan card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      subscription['plan'],
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(status.displayName),
                      backgroundColor: status == SubscriptionStatus.active
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '\$${subscription['price']}/month',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Expires: ${subscription['expiryDate']}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Features
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Features',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ...(subscription['features'] as List).map((feature) {
                      return ListTile(
                        leading: const Icon(Icons.check_circle, color: Colors.green),
                        title: Text(feature),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            AppButton(
              label: 'Upgrade Plan',
              onPressed: () {
                // Show upgrade options
              },
              icon: Icons.upgrade,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Manage Subscription',
              onPressed: () {
                // Manage subscription
              },
              icon: Icons.settings,
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }
}

