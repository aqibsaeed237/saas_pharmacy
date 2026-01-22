import 'package:equatable/equatable.dart';

/// Customer entity
class Customer extends Equatable {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? country;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? notes;
  final String tenantId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Customer({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.country,
    this.dateOfBirth,
    this.gender,
    this.notes,
    required this.tenantId,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? country,
    DateTime? dateOfBirth,
    String? gender,
    String? notes,
    String? tenantId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      notes: notes ?? this.notes,
      tenantId: tenantId ?? this.tenantId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        address,
        city,
        country,
        dateOfBirth,
        gender,
        notes,
        tenantId,
        isActive,
        createdAt,
        updatedAt,
      ];
}

