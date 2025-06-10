// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeliveryModelImpl _$$DeliveryModelImplFromJson(Map<String, dynamic> json) =>
    _$DeliveryModelImpl(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      deliveryAddress: json['deliveryAddress'] as String,
      items:
          (json['items'] as List<dynamic>)
              .map((e) => DeliveryItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      status: json['status'] as String,
      createdAt: _dateTimeFromTimestamp(json['createdAt']),
      updatedAt: _dateTimeFromTimestamp(json['updatedAt']),
    );

Map<String, dynamic> _$$DeliveryModelImplToJson(_$DeliveryModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'customerId': instance.customerId,
      'customerName': instance.customerName,
      'deliveryAddress': instance.deliveryAddress,
      'items': instance.items,
      'status': instance.status,
      'createdAt': _dateTimeToTimestamp(instance.createdAt),
      'updatedAt': _dateTimeToTimestamp(instance.updatedAt),
    };
