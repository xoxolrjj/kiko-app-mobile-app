// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationModelImpl _$$NotificationModelImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationModelImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  title: json['title'] as String,
  message: json['message'] as String,
  type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
  createdAt: _dateTimeFromTimestamp(json['createdAt']),
  updatedAt: _dateTimeFromTimestamp(json['updatedAt']),
  isRead: json['isRead'] as bool,
  orderId: json['orderId'] as String?,
  sellerId: json['sellerId'] as String?,
);

Map<String, dynamic> _$$NotificationModelImplToJson(
  _$NotificationModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'title': instance.title,
  'message': instance.message,
  'type': _$NotificationTypeEnumMap[instance.type]!,
  'createdAt': _dateTimeToTimestamp(instance.createdAt),
  'updatedAt': _dateTimeToTimestamp(instance.updatedAt),
  'isRead': instance.isRead,
  'orderId': instance.orderId,
  'sellerId': instance.sellerId,
};

const _$NotificationTypeEnumMap = {
  NotificationType.sellerApproval: 'sellerApproval',
  NotificationType.orderPlaced: 'orderPlaced',
  NotificationType.orderAccepted: 'orderAccepted',
  NotificationType.orderPreparing: 'orderPreparing',
  NotificationType.orderShipped: 'orderShipped',
  NotificationType.orderDelivered: 'orderDelivered',
  NotificationType.orderReceived: 'orderReceived',
  NotificationType.accountRestricted: 'accountRestricted',
  NotificationType.newOrder: 'newOrder',
  NotificationType.orderCancelled: 'orderCancelled',
  NotificationType.accountCreated: 'accountCreated',
  NotificationType.sellerApology: 'sellerApology',
  NotificationType.adminReply: 'adminReply',
};
