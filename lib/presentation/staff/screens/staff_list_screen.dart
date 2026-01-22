import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_enums.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/app_button.dart';

/// Staff list screen
class StaffListScreen extends StatelessWidget {
  const StaffListScreen({super.key});

  // Mock data - replace with BLoC when backend is ready
  final List<Map<String, dynamic>> mockStaff = const [
    {
      'id': '1',
      'name': 'John Doe',
      'email': 'john@example.com',
      'role': UserRole.admin,
      'isActive': true,
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'role': UserRole.manager,
      'isActive': true,
    },
    {
      'id': '3',
      'name': 'Bob Wilson',
      'email': 'bob@example.com',
      'role': UserRole.cashier,
      'isActive': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: mockStaff.isEmpty
          ? const EmptyView(
              message: 'No staff members found',
              icon: Icons.people_outline,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mockStaff.length,
              itemBuilder: (context, index) {
                final staff = mockStaff[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(staff['name'].toString()[0]),
                    ),
                    title: Text(staff['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(staff['email']),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                (staff['role'] as UserRole).displayName,
                                style: const TextStyle(fontSize: 12),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(
                                staff['isActive'] ? 'Active' : 'Inactive',
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: staff['isActive']
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'toggle',
                          child: Row(
                            children: [
                              Icon(
                                staff['isActive']
                                    ? Icons.block
                                    : Icons.check_circle,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(staff['isActive'] ? 'Disable' : 'Enable'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          context.go('/staff/edit/${staff['id']}');
                        }
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/staff/add'),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Staff'),
      ),
    );
  }
}

