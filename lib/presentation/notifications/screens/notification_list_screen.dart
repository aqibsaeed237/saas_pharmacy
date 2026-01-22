import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_enums.dart';

/// Notification list screen
class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  // Mock data
  final List<Map<String, dynamic>> mockNotifications = const [
    {
      'id': '1',
      'type': NotificationType.lowStock,
      'title': 'Low Stock Alert',
      'message': 'Paracetamol 500mg is running low (5 units remaining)',
      'isRead': false,
      'date': '2024-01-15 10:30',
    },
    {
      'id': '2',
      'type': NotificationType.expiry,
      'title': 'Expiry Alert',
      'message': 'Aspirin 100mg expires in 30 days',
      'isRead': false,
      'date': '2024-01-15 09:15',
    },
    {
      'id': '3',
      'type': NotificationType.system,
      'title': 'System Update',
      'message': 'New features available in version 2.0',
      'isRead': true,
      'date': '2024-01-14 14:20',
    },
  ];

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.lowStock:
        return Icons.warning_amber;
      case NotificationType.expiry:
        return Icons.calendar_today;
      case NotificationType.subscription:
        return Icons.card_membership;
      case NotificationType.system:
        return Icons.info;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.lowStock:
        return Colors.orange;
      case NotificationType.expiry:
        return Colors.red;
      case NotificationType.subscription:
        return Colors.blue;
      case NotificationType.system:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Mark all as read
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockNotifications.length,
        itemBuilder: (context, index) {
          final notification = mockNotifications[index];
          final type = notification['type'] as NotificationType;
          final isRead = notification['isRead'] as bool;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: isRead
                ? null
                : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getNotificationColor(type).withOpacity(0.2),
                child: Icon(
                  _getNotificationIcon(type),
                  color: _getNotificationColor(type),
                ),
              ),
              title: Text(
                notification['title'],
                style: TextStyle(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(notification['message']),
                  const SizedBox(height: 4),
                  Text(
                    notification['date'],
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              trailing: isRead
                  ? null
                  : Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
              onTap: () {
                // View notification details
              },
            ),
          );
        },
      ),
    );
  }
}

