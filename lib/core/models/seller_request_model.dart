import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiko_app_mobile_app/core/commons/utils.dart';

part 'seller_request_model.freezed.dart';
part 'seller_request_model.g.dart';

@freezed
class SellerRequestModel with _$SellerRequestModel {
  const factory SellerRequestModel({
    required String id,
    required String userId,
    required String name,
    required String email,
    required String phone,
    required String address,
    required String businessName,
    required String businessType,
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SellerRequestModel;

  factory SellerRequestModel.fromJson(Map<String, dynamic> json) =>
      _$SellerRequestModelFromJson(json);

  factory SellerRequestModel.fromSnapshot(DocumentSnapshot doc) {
    if (doc.data() == null) {
      return SellerRequestModel(
        id: '',
        userId: '',
        name: '',
        email: '',
        phone: '',
        address: '',
        businessName: '',
        businessType: '',
        status: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    final data = doc.data() as Map<String, dynamic>;
    return SellerRequestModel(
      id: doc.id,
      userId: cast<String>(data['userId']) ?? '',
      name: cast<String>(data['name']) ?? '',
      email: cast<String>(data['email']) ?? '',
      phone: cast<String>(data['phone']) ?? '',
      address: cast<String>(data['address']) ?? '',
      businessName: cast<String>(data['businessName']) ?? '',
      businessType: cast<String>(data['businessType']) ?? '',
      status: cast<String>(data['status']) ?? '',
      createdAt:
          (cast<Timestamp>(data['createdAt']) ?? Timestamp.now()).toDate(),
      updatedAt:
          (cast<Timestamp>(data['updatedAt']) ?? Timestamp.now()).toDate(),
    );
  }
}
