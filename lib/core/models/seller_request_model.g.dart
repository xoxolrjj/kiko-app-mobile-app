// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SellerRequestModelImpl _$$SellerRequestModelImplFromJson(
  Map<String, dynamic> json,
) => _$SellerRequestModelImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String,
  address: json['address'] as String,
  businessName: json['businessName'] as String,
  businessType: json['businessType'] as String,
  status: json['status'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$SellerRequestModelImplToJson(
  _$SellerRequestModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'address': instance.address,
  'businessName': instance.businessName,
  'businessType': instance.businessType,
  'status': instance.status,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
