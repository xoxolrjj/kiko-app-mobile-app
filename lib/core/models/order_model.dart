import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiko_app_mobile_app/core/commons/utils.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

enum OrderStatus { pending, accepted, preparing, ready, completed, cancelled }

@freezed
class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    required String buyerId,
    required String buyerName,
    required String buyerPhone,
    required String sellerId,
    required String sellerName,
    required List<OrderItem> items,
    required double totalAmount,
    required String deliveryAddress,
    required OrderStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? acceptedAt,
    DateTime? readyAt,
    DateTime? completedAt,
    String? notes,
    String? rejectionReason,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  factory OrderModel.fromSnapshot(DocumentSnapshot doc) {
    if (doc.data() == null) {
      return OrderModel(
        id: '',
        buyerId: '',
        buyerName: '',
        buyerPhone: '',
        sellerId: '',
        sellerName: '',
        items: [],
        totalAmount: 0.0,
        deliveryAddress: '',
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    final data = doc.data() as Map<String, dynamic>;
    final itemsList = cast<List>(data['items']) ?? [];
    final orderItems =
        itemsList
            .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
            .toList();

    // Helper function to parse DateTime from either String or Timestamp
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return OrderModel(
      id: doc.id,
      buyerId: cast<String>(data['buyerId']) ?? '',
      buyerName: cast<String>(data['buyerName']) ?? '',
      buyerPhone: cast<String>(data['buyerPhone']) ?? '',
      sellerId: cast<String>(data['sellerId']) ?? '',
      sellerName: cast<String>(data['sellerName']) ?? '',
      items: orderItems,
      totalAmount: (cast<num>(data['totalAmount']) ?? 0).toDouble(),
      deliveryAddress: cast<String>(data['deliveryAddress']) ?? '',
      status: OrderStatus.values.firstWhere(
        (e) => e.name == cast<String>(data['status']),
        orElse: () => OrderStatus.pending,
      ),
      createdAt: parseDateTime(data['createdAt']),
      updatedAt: parseDateTime(data['updatedAt']),
      acceptedAt:
          data['acceptedAt'] != null ? parseDateTime(data['acceptedAt']) : null,
      readyAt: data['readyAt'] != null ? parseDateTime(data['readyAt']) : null,
      completedAt:
          data['completedAt'] != null
              ? parseDateTime(data['completedAt'])
              : null,
      notes: cast<String>(data['notes']),
      rejectionReason: cast<String>(data['rejectionReason']),
    );
  }
}

@freezed
class OrderItem with _$OrderItem {
  const factory OrderItem({
    required String productId,
    required String productName,
    required String productImage,
    required int quantity,
    required double pricePerUnit,
    required double totalPrice,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      productId: cast<String>(data['productId']) ?? '',
      productName: cast<String>(data['productName']) ?? '',
      productImage: cast<String>(data['productImage']) ?? '',
      quantity: cast<int>(data['quantity']) ?? 0,
      pricePerUnit: (cast<num>(data['pricePerUnit']) ?? 0).toDouble(),
      totalPrice: (cast<num>(data['totalPrice']) ?? 0).toDouble(),
    );
  }
}
