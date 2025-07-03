import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiko_app_mobile_app/core/commons/utils.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

enum NotificationType {
  sellerApproval,
  orderPlaced,
  orderAccepted,
  orderPreparing,
  orderShipped,
  orderDelivered,
  orderReceived,
  accountRestricted,
  newOrder,
  orderCancelled,
  accountCreated,
  sellerApology,
  adminReply,
}

@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required String id,
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required DateTime createdAt,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required DateTime updatedAt,
    required bool isRead,
    String? orderId,
    String? sellerId,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  factory NotificationModel.fromSnapshot(DocumentSnapshot doc) {
    if (doc.data() == null) {
      return NotificationModel(
        updatedAt: DateTime.now(),
        id: '',
        userId: '',
        title: '',
        message: '',
        type: NotificationType.values.first,
        createdAt: DateTime.now(),
        isRead: false,
      );
    }

    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] as String,
      title: data['title'] as String,
      message: data['message'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${data['type']}',
      ),
      createdAt: _dateTimeFromTimestamp(data['createdAt']),
      updatedAt: _dateTimeFromTimestamp(data['updatedAt']),
      isRead: data['isRead'] as bool,
      orderId: data['orderId'] as String?,
      sellerId: data['sellerId'] as String?,
    );
  }
}

DateTime _dateTimeFromTimestamp(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.parse(value);
  return DateTime.now();
}

Timestamp _dateTimeToTimestamp(DateTime dateTime) {
  return Timestamp.fromDate(dateTime);
}
