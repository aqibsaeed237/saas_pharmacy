import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../domain/entities/customer_address.dart';

/// Customer address book screen
class CustomerAddressBookScreen extends StatelessWidget {
  final String customerId;
  final String customerName;

  const CustomerAddressBookScreen({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    // Mock addresses
    final addresses = <CustomerAddress>[
      CustomerAddress(
        id: 'addr1',
        customerId: customerId,
        addressLine1: '123 Main Street',
        addressLine2: 'Apt 4B',
        city: 'New York',
        state: 'NY',
        postalCode: '10001',
        country: 'USA',
        isDefault: true,
        addressType: 'home',
        tenantId: 'tenant1',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      CustomerAddress(
        id: 'addr2',
        customerId: customerId,
        addressLine1: '456 Work Avenue',
        city: 'New York',
        state: 'NY',
        postalCode: '10002',
        country: 'USA',
        isDefault: false,
        addressType: 'work',
        tenantId: 'tenant1',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${loc?.translate('addresses') ?? 'Addresses'} - $customerName'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push(
                '/customers/address/add',
                extra: {'customerId': customerId},
              );
            },
            tooltip: loc?.translate('addAddress') ?? 'Add Address',
          ),
        ],
      ),
      body: addresses.isEmpty
          ? Center(
              child: Text(loc?.translate('noAddresses') ?? 'No addresses found'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(
                      address.addressType == 'home'
                          ? Icons.home
                          : address.addressType == 'work'
                              ? Icons.work
                              : Icons.location_on,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            address.addressType?.toUpperCase() ?? 'ADDRESS',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (address.isDefault)
                          Chip(
                            label: Text(
                              loc?.translate('default') ?? 'Default',
                              style: const TextStyle(fontSize: 10),
                            ),
                            labelStyle: const TextStyle(fontSize: 10),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(address.fullAddress),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Text(loc?.translate('edit') ?? 'Edit'),
                          onTap: () {
                            Future.delayed(const Duration(milliseconds: 100), () {
                              context.push(
                                '/customers/address/edit',
                                extra: {'address': address},
                              );
                            });
                          },
                        ),
                        if (!address.isDefault)
                          PopupMenuItem(
                            child: Text(loc?.translate('setAsDefault') ?? 'Set as Default'),
                            onTap: () {
                              // Handle set as default
                            },
                          ),
                        PopupMenuItem(
                          child: Text(
                            loc?.translate('delete') ?? 'Delete',
                            style: const TextStyle(color: Colors.red),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(loc?.translate('delete') ?? 'Delete'),
                                content: Text(
                                  loc?.translate('deleteAddressConfirmation') ??
                                      'Are you sure you want to delete this address?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => context.pop(),
                                    child: Text(loc?.translate('cancel') ?? 'Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Handle delete
                                      context.pop();
                                    },
                                    child: Text(
                                      loc?.translate('delete') ?? 'Delete',
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

