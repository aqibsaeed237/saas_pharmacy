import 'package:equatable/equatable.dart';

enum ServiceType { delivery, collection, dineIn }

enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

/// Store timing entity
class StoreTiming extends Equatable {
  final String id;
  final String storeId;
  final ServiceType serviceType;
  final DayOfWeek day;
  final String startTime; // Format: "HH:mm"
  final String endTime; // Format: "HH:mm"
  final bool isOpenAllDay;
  final bool isClosed;
  final String tenantId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const StoreTiming({
    required this.id,
    required this.storeId,
    required this.serviceType,
    required this.day,
    required this.startTime,
    required this.endTime,
    this.isOpenAllDay = false,
    this.isClosed = false,
    required this.tenantId,
    required this.createdAt,
    this.updatedAt,
  });

  StoreTiming copyWith({
    String? id,
    String? storeId,
    ServiceType? serviceType,
    DayOfWeek? day,
    String? startTime,
    String? endTime,
    bool? isOpenAllDay,
    bool? isClosed,
    String? tenantId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StoreTiming(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      serviceType: serviceType ?? this.serviceType,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isOpenAllDay: isOpenAllDay ?? this.isOpenAllDay,
      isClosed: isClosed ?? this.isClosed,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        storeId,
        serviceType,
        day,
        startTime,
        endTime,
        isOpenAllDay,
        isClosed,
        tenantId,
        createdAt,
        updatedAt,
      ];
}

