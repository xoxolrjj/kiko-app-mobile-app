import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiko_app_mobile_app/core/commons/utils.dart';
import 'package:kiko_app_mobile_app/core/models/delivery_item_model.dart';

part 'delivery_model.freezed.dart';
part 'delivery_model.g.dart';

@freezed
class DeliveryModel with _$DeliveryModel {
  const factory DeliveryModel({
    required String id,
    required String orderId,
    required String customerId,
    required String customerName,
    required String deliveryAddress,
    required List<DeliveryItem> items,
    required String status,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required DateTime createdAt,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required DateTime updatedAt,
  }) = _DeliveryModel;

  factory DeliveryModel.fromJson(Map<String, dynamic> json) =>
      _$DeliveryModelFromJson(json);

  factory DeliveryModel.fromSnapshot(DocumentSnapshot doc) {
    if (doc.data() == null) {
      return DeliveryModel(
        id: doc.id,
        orderId: '',
        customerId: '',
        customerName: '',
        deliveryAddress: '',
        items: [],
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    final data = doc.data() as Map<String, dynamic>;
    final itemsList = cast<List>(data['items']) ?? [];
    final deliveryItems =
        itemsList
            .map((item) => DeliveryItem.fromJson(item as Map<String, dynamic>))
            .toList();

    return DeliveryModel(
      id: doc.id,
      orderId: cast<String>(data['orderId']) ?? '',
      customerId: cast<String>(data['customerId']) ?? '',
      customerName: cast<String>(data['customerName']) ?? '',
      deliveryAddress: cast<String>(data['deliveryAddress']) ?? '',
      items: deliveryItems,
      status: cast<String>(data['status']) ?? 'pending',
      createdAt: _dateTimeFromTimestamp(data['createdAt']),
      updatedAt: _dateTimeFromTimestamp(data['updatedAt']),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'customerId': customerId,
      'customerName': customerName,
      'deliveryAddress': deliveryAddress,
      'items': items.map((item) => item.toJson()).toList(),
      'status': status,
    };
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
