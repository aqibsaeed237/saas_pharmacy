import 'package:equatable/equatable.dart';

/// Customer address entity
class CustomerAddress extends Equatable {
  final String id;
  final String customerId;
  final String addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String? landmark;
  final bool isDefault;
  final String? addressType; // 'home', 'work', 'other'
  final String tenantId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CustomerAddress({
    required this.id,
    required this.customerId,
    required this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.landmark,
    required this.isDefault,
    this.addressType,
    required this.tenantId,
    required this.createdAt,
    this.updatedAt,
  });

  CustomerAddress copyWith({
    String? id,
    String? customerId,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? landmark,
    bool? isDefault,
    String? addressType,
    String? tenantId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerAddress(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      landmark: landmark ?? this.landmark,
      isDefault: isDefault ?? this.isDefault,
      addressType: addressType ?? this.addressType,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get fullAddress {
    final parts = <String>[
      addressLine1,
      if (addressLine2 != null) addressLine2!,
      if (city != null) city!,
      if (state != null) state!,
      if (postalCode != null) postalCode!,
      if (country != null) country!,
    ];
    return parts.where((p) => p.isNotEmpty).join(', ');
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        addressLine1,
        addressLine2,
        city,
        state,
        postalCode,
        country,
        landmark,
        isDefault,
        addressType,
        tenantId,
        createdAt,
        updatedAt,
      ];
}

