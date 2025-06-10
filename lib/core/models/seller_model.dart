import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiko_app_mobile_app/core/commons/utils.dart';


part 'seller_model.freezed.dart';
 
@freezed
class SellerModel with _$SellerModel {
  factory SellerModel({
    required String id,
    required String userId,
    required String shopName,
    required String contactNumber,
    required String shopLocation,
 required String idVerificationUrl,
    required String faceVerificationUrl,
 
    required DateTime createdAt,
  }) = _SellerModel;

  SellerModel._();

  factory SellerModel.isEmpty() {
    return SellerModel(
      id: '',
      userId: '',
      shopName: '',

      contactNumber: '',
      shopLocation: '',
      idVerificationUrl: '',
      faceVerificationUrl: '',
      
      createdAt: DateTime.now(),
    );
  }

  factory SellerModel.fromSnapshot(DocumentSnapshot doc) {
    if (doc.data() == null) {
      return SellerModel.isEmpty();
    }

    final json = doc.data() as Map<String, dynamic>;

    return SellerModel(
      id: doc.id,
      userId: cast<String>(json['userId']) ?? '',
      shopName: cast<String>(json['shopName']) ?? '',
      contactNumber: cast<String>(json['contactNumber']) ?? '',
      shopLocation: cast<String>(json['shopLocation']) ?? '',
      idVerificationUrl: cast<String>(json['idImagePath']) ?? '',
      faceVerificationUrl: cast<String>(json['faceImagePath']) ?? '',

      createdAt: (cast<Timestamp>(json['createdAt']) ?? Timestamp.now()).toDate(),
    );
  }

  factory SellerModel.fromJson(Map<String, dynamic> json) {
    return SellerModel(
       id: cast<String>(json['id']) ?? '',
      userId: cast<String>(json['userId']) ?? '',
      shopName: cast<String>(json['shopName']) ?? '',
      contactNumber: cast<String>(json['contactNumber']) ?? '',
           shopLocation: cast<String>(json['shopLocation']) ?? '',

     idVerificationUrl: cast<String>(json['idImagePath']) ?? '',
      faceVerificationUrl: cast<String>(json['faceImagePath']) ?? '',

      createdAt: (cast<Timestamp>(json['createdAt']) ?? Timestamp.now()).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'shopName': shopName,
      'contactNumber': contactNumber,
      'shopLocation': shopLocation,
      'shopLocation': shopLocation,
      'idVerificationUrl': idVerificationUrl,
   
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
