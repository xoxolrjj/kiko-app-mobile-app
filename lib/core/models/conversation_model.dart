import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiko_app_mobile_app/core/commons/utils.dart';

part 'conversation_model.freezed.dart';
part 'conversation_model.g.dart';

@freezed
class ConversationModel with _$ConversationModel {
  const factory ConversationModel({
    required String id,
    required String buyerId,
    required String buyerName,
    required String sellerId,
    required String sellerName,
    required String orderId,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? lastMessage,
    DateTime? lastMessageTime,
  }) = _ConversationModel;

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);

  factory ConversationModel.fromSnapshot(DocumentSnapshot doc) {
    if (doc.data() == null) {
      return ConversationModel(
        id: '',
        buyerId: '',
        buyerName: '',
        sellerId: '',
        sellerName: '',
        orderId: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    final data = doc.data() as Map<String, dynamic>;
    return ConversationModel(
      id: doc.id,
      buyerId: cast<String>(data['buyerId']) ?? '',
      buyerName: cast<String>(data['buyerName']) ?? '',
      sellerId: cast<String>(data['sellerId']) ?? '',
      sellerName: cast<String>(data['sellerName']) ?? '',
      orderId: cast<String>(data['orderId']) ?? '',
      createdAt:
          (cast<Timestamp>(data['createdAt']) ?? Timestamp.now()).toDate(),
      updatedAt:
          (cast<Timestamp>(data['updatedAt']) ?? Timestamp.now()).toDate(),
      lastMessage: cast<String>(data['lastMessage']),
      lastMessageTime: cast<Timestamp>(data['lastMessageTime'])?.toDate(),
    );
  }
}

@freezed
class MessageModel with _$MessageModel {
  const factory MessageModel({
    required String id,
    required String conversationId,
    required String senderId,
    required String senderName,
    required String content,
    required DateTime createdAt,
    required bool isRead,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  factory MessageModel.fromSnapshot(DocumentSnapshot doc) {
    if (doc.data() == null) {
      return MessageModel(
        id: '',
        conversationId: '',
        senderId: '',
        senderName: '',
        content: '',
        createdAt: DateTime.now(),
        isRead: false,
      );
    }

    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      conversationId: cast<String>(data['conversationId']) ?? '',
      senderId: cast<String>(data['senderId']) ?? '',
      senderName: cast<String>(data['senderName']) ?? '',
      content: cast<String>(data['content']) ?? '',
      createdAt:
          (cast<Timestamp>(data['createdAt']) ?? Timestamp.now()).toDate(),
      isRead: cast<bool>(data['isRead']) ?? false,
    );
  }
}
