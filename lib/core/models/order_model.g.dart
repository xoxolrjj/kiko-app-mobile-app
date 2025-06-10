// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderModelImpl _$$OrderModelImplFromJson(Map<String, dynamic> json) =>
    _$OrderModelImpl(
      id: json['id'] as String,
      buyerId: json['buyerId'] as String,
      buyerName: json['buyerName'] as String,
      buyerPhone: json['buyerPhone'] as String,
      sellerId: json['sellerId'] as String,
      sellerName: json['sellerName'] as String,
      items:
          (json['items'] as List<dynamic>)
              .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      deliveryAddress: json['deliveryAddress'] as String,
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      acceptedAt:
          json['acceptedAt'] == null
              ? null
              : DateTime.parse(json['acceptedAt'] as String),
      readyAt:
          json['readyAt'] == null
              ? null
              : DateTime.parse(json['readyAt'] as String),
      shippedAt:
          json['shippedAt'] == null
              ? null
              : DateTime.parse(json['shippedAt'] as String),
      deliveredAt:
          json['deliveredAt'] == null
              ? null
              : DateTime.parse(json['deliveredAt'] as String),
      notes: json['notes'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
    );

Map<String, dynamic> _$$OrderModelImplToJson(_$OrderModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'buyerId': instance.buyerId,
      'buyerName': instance.buyerName,
      'buyerPhone': instance.buyerPhone,
      'sellerId': instance.sellerId,
      'sellerName': instance.sellerName,
      'items': instance.items,
      'totalAmount': instance.totalAmount,
      'deliveryAddress': instance.deliveryAddress,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'acceptedAt': instance.acceptedAt?.toIso8601String(),
      'readyAt': instance.readyAt?.toIso8601String(),
      'shippedAt': instance.shippedAt?.toIso8601String(),
      'deliveredAt': instance.deliveredAt?.toIso8601String(),
      'notes': instance.notes,
      'rejectionReason': instance.rejectionReason,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.accepted: 'accepted',
  OrderStatus.preparing: 'preparing',
  OrderStatus.ready: 'ready',
  OrderStatus.shipped: 'shipped',
  OrderStatus.delivered: 'delivered',
  OrderStatus.cancelled: 'cancelled',
};

_$OrderItemImpl _$$OrderItemImplFromJson(Map<String, dynamic> json) =>
    _$OrderItemImpl(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productImage: json['productImage'] as String,
      quantity: (json['quantity'] as num).toInt(),
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );

Map<String, dynamic> _$$OrderItemImplToJson(_$OrderItemImpl instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'productImage': instance.productImage,
      'quantity': instance.quantity,
      'pricePerUnit': instance.pricePerUnit,
      'totalPrice': instance.totalPrice,
    };
