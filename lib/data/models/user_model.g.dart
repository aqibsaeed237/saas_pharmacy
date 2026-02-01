// // GENERATED CODE - DO NOT MODIFY BY HAND
//
// part of 'user_model.dart';
//
// // **************************************************************************
// // JsonSerializableGenerator
// // **************************************************************************
//
//
// UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
//       id: json['id'] as String,
//       email: json['email'] as String,
//       firstName: json['firstName'] as String,
//       lastName: json['lastName'] as String,
//       role: $enumDecode(_$UserRoleEnumMap, json['role']),
//       phoneNumber: json['phoneNumber'] as String?,
//       avatarUrl: json['avatarUrl'] as String?,
//       isActive: json['isActive'] as bool,
//       tenantId: json['tenantId'] as String,
//       createdAt: DateTime.parse(json['createdAt'] as String),
//       updatedAt: json['updatedAt'] == null
//           ? null
//           : DateTime.parse(json['updatedAt'] as String),
//     );
//
// Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
//       'id': instance.id,
//       'email': instance.email,
//       'firstName': instance.firstName,
//       'lastName': instance.lastName,
//       'role': _$UserRoleEnumMap[instance.role]!,
//       'phoneNumber': instance.phoneNumber,
//       'avatarUrl': instance.avatarUrl,
//       'isActive': instance.isActive,
//       'tenantId': instance.tenantId,
//       'createdAt': instance.createdAt.toIso8601String(),
//       'updatedAt': instance.updatedAt?.toIso8601String(),
//     };
//
// const _$UserRoleEnumMap = {
//   UserRole.admin: 'admin',
//   UserRole.manager: 'manager',
//   UserRole.cashier: 'cashier',
// };
