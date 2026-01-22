import 'package:equatable/equatable.dart';

/// Store/Branch entity
class Store extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String? phone;
  final String? email;
  final String? imageUrl;
  final bool isActive;
  final String tenantId;
  final String? storeId; // Parent store ID if this is a sub-branch
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Store({
    required this.id,
    required this.name,
    this.description,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.phone,
    this.email,
    this.imageUrl,
    required this.isActive,
    required this.tenantId,
    this.storeId,
    required this.createdAt,
    this.updatedAt,
  });

  Store copyWith({
    String? id,
    String? name,
    String? description,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? phone,
    String? email,
    String? imageUrl,
    bool? isActive,
    String? tenantId,
    String? storeId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      tenantId: tenantId ?? this.tenantId,
      storeId: storeId ?? this.storeId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        addressLine1,
        addressLine2,
        city,
        state,
        postalCode,
        country,
        phone,
        email,
        imageUrl,
        isActive,
        tenantId,
        storeId,
        createdAt,
        updatedAt,
      ];
}

