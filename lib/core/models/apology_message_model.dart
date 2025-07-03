import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiko_app_mobile_app/core/commons/utils.dart';

enum ApologyStatus { pending, reviewed, resolved }

class ApologyMessageModel {
  final String id;
  final String sellerId;
  final String sellerName;
  final String sellerEmail;
  final String message;
  final ApologyStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? adminResponse;
  final String? reviewedBy;
  final DateTime? reviewedAt;

  ApologyMessageModel({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.sellerEmail,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.adminResponse,
    this.reviewedBy,
    this.reviewedAt,
  });

  factory ApologyMessageModel.fromSnapshot(DocumentSnapshot doc) {
    if (doc.data() == null) {
      return ApologyMessageModel(
        id: '',
        sellerId: '',
        sellerName: '',
        sellerEmail: '',
        message: '',
        status: ApologyStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    final data = doc.data() as Map<String, dynamic>;
    return ApologyMessageModel(
      id: doc.id,
      sellerId: cast<String>(data['sellerId']) ?? '',
      sellerName: cast<String>(data['sellerName']) ?? '',
      sellerEmail: cast<String>(data['sellerEmail']) ?? '',
      message: cast<String>(data['message']) ?? '',
      status: ApologyStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ApologyStatus.pending,
      ),
      createdAt:
          (cast<Timestamp>(data['createdAt']) ?? Timestamp.now()).toDate(),
      updatedAt:
          (cast<Timestamp>(data['updatedAt']) ?? Timestamp.now()).toDate(),
      adminResponse: cast<String>(data['adminResponse']),
      reviewedBy: cast<String>(data['reviewedBy']),
      reviewedAt:
          data['reviewedAt'] != null
              ? (cast<Timestamp>(data['reviewedAt'])!).toDate()
              : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'id': id,
    'sellerId': sellerId,
    'sellerName': sellerName,
    'sellerEmail': sellerEmail,
    'message': message,
    'status': status.name,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'adminResponse': adminResponse,
    'reviewedBy': reviewedBy,
    'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
  };

  ApologyMessageModel copyWith({
    String? id,
    String? sellerId,
    String? sellerName,
    String? sellerEmail,
    String? message,
    ApologyStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? adminResponse,
    String? reviewedBy,
    DateTime? reviewedAt,
  }) {
    return ApologyMessageModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerEmail: sellerEmail ?? this.sellerEmail,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      adminResponse: adminResponse ?? this.adminResponse,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }
}
