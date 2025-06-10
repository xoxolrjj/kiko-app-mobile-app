import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiko_app_mobile_app/core/commons/utils.dart';

part 'delivery_item_model.freezed.dart';

@freezed
class DeliveryItem with _$DeliveryItem {
    factory DeliveryItem({
    @Default('') String productId,
    @Default('') String productName,
    @Default(0) int quantity,
    @Default(0.0) double price,
  }) = _DeliveryItem;
  
  DeliveryItem._();


  factory DeliveryItem.isEmpty() {
    return DeliveryItem(
      productId: '',
      productName: '',
      quantity: 0,
      price: 0.0,
    );
  }

  factory DeliveryItem.fromSnapshot(DocumentSnapshot doc) {
    if(doc.data() == null) {
      return DeliveryItem.isEmpty();
    }
    final data = doc.data() as Map<String, dynamic>;
    return DeliveryItem(
      productId: cast<String>(data['productId']) ?? '',
      productName: cast<String>(data['productName']) ?? '',
      quantity: cast<int>(data['quantity']) ?? 0,
      price: (cast<num>(data['price']) ?? 0).toDouble(),
    );
  }

  factory DeliveryItem.fromJson(Map<String, dynamic> data) {
    return DeliveryItem(
      productId: cast<String>(data['productId']) ?? '',
      productName: cast<String>(data['productName']) ?? '',
      quantity: cast<int>(data['quantity']) ?? 0,
      price: (cast<num>(data['price']) ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'quantity': quantity,
    'price': price,
  };
}
