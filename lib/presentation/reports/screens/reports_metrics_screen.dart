import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';

/// Main Reports Metrics screen with 3 metric cards
class ReportsMetricsScreen extends StatelessWidget {
  const ReportsMetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.translate('reports') ?? 'Reports'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Sales and Revenue Metrics Card
          _buildMetricCard(
            context,
            title: loc?.translate('salesAndRevenueMetrics') ?? 'Sales and Revenue Metrics',
            description: loc?.translate('trackSalesRevenue') ?? 'Track sales and revenue metrics with detailed insights.',
            icon: Icons.bar_chart,
            color: Colors.orange,
            onTap: () {
              context.pushNamed('salesRevenueMetrics');
            },
          ),
          const SizedBox(height: 16),
          // Customer Metrics Card
          _buildMetricCard(
            context,
            title: loc?.translate('customerMetrics') ?? 'Customer Metrics',
            description: loc?.translate('analyzeCustomerBehavior') ?? 'Analyze customer behavior and engagement patterns.',
            icon: Icons.people,
            color: Colors.pink,
            onTap: () {
              context.pushNamed('customerMetrics');
            },
          ),
          const SizedBox(height: 16),
          // Order Metrics Card
          _buildMetricCard(
            context,
            title: loc?.translate('orderMetrics') ?? 'Order Metrics',
            description: loc?.translate('monitorOrderTrends') ?? 'Monitor order trends and operational efficiency.',
            icon: Icons.shopping_cart,
            color: Colors.green,
            onTap: () {
              context.pushNamed('orderMetrics');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

