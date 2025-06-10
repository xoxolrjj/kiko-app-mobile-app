import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiko_app_mobile_app/core/commons/utils.dart';

enum PhilippineIDType {
  psaBirthCertificate,
  passport,
  driversLicense,
  votersId,
  sssId,
  tinId,
  philHealthId,
  prcId,
  seniorCitizenId,
  pwdId,
  postalId,
  barangayId,
  nationalID,
  farmerID,
}

enum VerificationStatus { pending, approved, rejected }

class SellerVerificationRequest {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;

  // Business Information

  final String shopName;
  final String contactNumber;
  final String shopLocation;

  // ID Verification
  final PhilippineIDType idType;
  final String idNumber;
  final String idImageUrl;

  // Biometric Verification
  final String faceVerificationUrl;
  final bool biometricVerified;
  final String biometricData; // Encrypted biometric hash

  // Status and Timestamps
  final VerificationStatus status;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? approvedAt;
  final String? approvedBy; // Admin ID who approved

  SellerVerificationRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.shopName,
    required this.contactNumber,
    required this.shopLocation,
    required this.idType,
    required this.idNumber,
    required this.idImageUrl,
    required this.faceVerificationUrl,
    required this.biometricVerified,
    required this.biometricData,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
    this.approvedAt,
    this.approvedBy,
  });

  factory SellerVerificationRequest.empty() {
    return SellerVerificationRequest(
      id: '',
      userId: '',
      userName: '',
      userEmail: '',
      userPhone: '',

      shopName: '',
      contactNumber: '',
      shopLocation: '',
      idType: PhilippineIDType.psaBirthCertificate,
      idNumber: '',
      idImageUrl: '',
      faceVerificationUrl: '',
      biometricVerified: false,
      biometricData: '',
      status: VerificationStatus.pending,
      rejectionReason: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      approvedAt: null,
      approvedBy: null,
    );
  }

  factory SellerVerificationRequest.fromSnapshot(DocumentSnapshot doc) {
    if (doc.data() == null) {
      return SellerVerificationRequest.empty();
    }

    final data = doc.data() as Map<String, dynamic>;
    return SellerVerificationRequest(
      id: doc.id,
      userId: cast<String>(data['userId']) ?? '',
      userName: cast<String>(data['userName']) ?? '',
      userEmail: cast<String>(data['userEmail']) ?? '',
      userPhone: cast<String>(data['userPhone']) ?? '',
      shopName: cast<String>(data['shopName']) ?? '',
      contactNumber: cast<String>(data['contactNumber']) ?? '',
      shopLocation: cast<String>(data['shopLocation']) ?? '',
      idType: PhilippineIDType.values.firstWhere(
        (e) => e.name == cast<String>(data['idType']),
        orElse: () => PhilippineIDType.psaBirthCertificate,
      ),
      idNumber: cast<String>(data['idNumber']) ?? '',
      idImageUrl: cast<String>(data['idImageUrl']) ?? '',
      faceVerificationUrl: cast<String>(data['faceVerificationUrl']) ?? '',
      biometricVerified: cast<bool>(data['biometricVerified']) ?? false,
      biometricData: cast<String>(data['biometricData']) ?? '',
      status: VerificationStatus.values.firstWhere(
        (e) => e.name == cast<String>(data['status']),
        orElse: () => VerificationStatus.pending,
      ),
      rejectionReason: cast<String>(data['rejectionReason']),
      createdAt:
          (cast<Timestamp>(data['createdAt']) ?? Timestamp.now()).toDate(),
      updatedAt:
          (cast<Timestamp>(data['updatedAt']) ?? Timestamp.now()).toDate(),
      approvedAt: cast<Timestamp>(data['approvedAt'])?.toDate(),
      approvedBy: cast<String>(data['approvedBy']),
    );
  }

  factory SellerVerificationRequest.fromJson(Map<String, dynamic> data) {
    return SellerVerificationRequest(
      id: cast<String>(data['id']) ?? '',
      userId: cast<String>(data['userId']) ?? '',
      userName: cast<String>(data['userName']) ?? '',
      userEmail: cast<String>(data['userEmail']) ?? '',
      userPhone: cast<String>(data['userPhone']) ?? '',
      shopName: cast<String>(data['shopName']) ?? '',
      contactNumber: cast<String>(data['contactNumber']) ?? '',
      shopLocation: cast<String>(data['shopLocation']) ?? '',
      idType: PhilippineIDType.values.firstWhere(
        (e) => e.name == cast<String>(data['idType']),
        orElse: () => PhilippineIDType.psaBirthCertificate,
      ),
      idNumber: cast<String>(data['idNumber']) ?? '',
      idImageUrl: cast<String>(data['idImageUrl']) ?? '',
      faceVerificationUrl: cast<String>(data['faceVerificationUrl']) ?? '',
      biometricVerified: cast<bool>(data['biometricVerified']) ?? false,
      biometricData: cast<String>(data['biometricData']) ?? '',
      status: VerificationStatus.values.firstWhere(
        (e) => e.name == cast<String>(data['status']),
        orElse: () => VerificationStatus.pending,
      ),
      rejectionReason: cast<String>(data['rejectionReason']),
      createdAt:
          (cast<Timestamp>(data['createdAt']) ?? Timestamp.now()).toDate(),
      updatedAt:
          (cast<Timestamp>(data['updatedAt']) ?? Timestamp.now()).toDate(),
      approvedAt: cast<Timestamp>(data['approvedAt'])?.toDate(),
      approvedBy: cast<String>(data['approvedBy']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'shopName': shopName,
      'contactNumber': contactNumber,
      'shopLocation': shopLocation,
      'idType': idType.name,
      'idNumber': idNumber,
      'idImageUrl': idImageUrl,
      'faceVerificationUrl': faceVerificationUrl,
      'biometricVerified': biometricVerified,
      'biometricData': biometricData,
      'status': status.name,
      'rejectionReason': rejectionReason,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'approvedBy': approvedBy,
    };
  }

  SellerVerificationRequest copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,

    String? shopName,
    String? contactNumber,
    String? shopLocation,

    PhilippineIDType? idType,
    String? idNumber,
    String? idImageUrl,
    String? faceVerificationUrl,
    bool? biometricVerified,
    String? biometricData,
    VerificationStatus? status,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? approvedAt,
    String? approvedBy,
  }) {
    return SellerVerificationRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,

      shopName: shopName ?? this.shopName,
      contactNumber: contactNumber ?? this.contactNumber,
      shopLocation: shopLocation ?? this.shopLocation,
      idType: idType ?? this.idType,
      idNumber: idNumber ?? this.idNumber,
      idImageUrl: idImageUrl ?? this.idImageUrl,
      faceVerificationUrl: faceVerificationUrl ?? this.faceVerificationUrl,
      biometricVerified: biometricVerified ?? this.biometricVerified,
      biometricData: biometricData ?? this.biometricData,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
    );
  }

  String get idTypeDisplayName {
    switch (idType) {
      case PhilippineIDType.psaBirthCertificate:
        return 'PSA Birth Certificate';
      case PhilippineIDType.passport:
        return 'Philippine Passport';
      case PhilippineIDType.driversLicense:
        return "Driver's License";
      case PhilippineIDType.votersId:
        return "Voter's ID";
      case PhilippineIDType.sssId:
        return 'SSS ID';
      case PhilippineIDType.tinId:
        return 'TIN ID';
      case PhilippineIDType.philHealthId:
        return 'PhilHealth ID';
      case PhilippineIDType.prcId:
        return 'PRC ID';
      case PhilippineIDType.seniorCitizenId:
        return 'Senior Citizen ID';
      case PhilippineIDType.pwdId:
        return 'PWD ID';
      case PhilippineIDType.postalId:
        return 'Postal ID';
      case PhilippineIDType.barangayId:
        return 'Barangay ID';
      case PhilippineIDType.nationalID:
        return 'National ID';
      case PhilippineIDType.farmerID:
        return 'Farmer ID';
    }
  }
}
