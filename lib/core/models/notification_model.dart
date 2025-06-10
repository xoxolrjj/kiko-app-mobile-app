import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiko_app_mobile_app/core/commons/utils.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required String id,
    required String title,
    required String message,
    required String type,
    required bool isRead,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  factory NotificationModel.fromSnapshot(DocumentSnapshot doc) {
    if (doc.data() == null) {
      return NotificationModel(
        id: '',
        title: '',
        message: '',
        type: '',
        isRead: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: cast<String>(data['title']) ?? '',
      message: cast<String>(data['message']) ?? '',
      type: cast<String>(data['type']) ?? '',
      isRead: cast<bool>(data['isRead']) ?? false,
      createdAt:
          (cast<Timestamp>(data['createdAt']) ?? Timestamp.now()).toDate(),
      updatedAt:
          (cast<Timestamp>(data['updatedAt']) ?? Timestamp.now()).toDate(),
    );
  }
}
