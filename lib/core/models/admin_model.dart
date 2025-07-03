import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiko_app_mobile_app/core/commons/utils.dart';

class AdminModel {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isActive;
  final List<String> permissions;

  AdminModel({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.photoUrl,
    required this.createdAt,
    required this.lastLoginAt,
    required this.isActive,
    required this.permissions,
  });

  factory AdminModel.isEmpty() {
    return AdminModel(
      id: '',
      email: '',
      name: '',
      phoneNumber: null,
      photoUrl: null,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      isActive: false,
      permissions: [],
    );
  }

  factory AdminModel.fromSnapshot(DocumentSnapshot doc) {
    if (doc.data() == null) {
      return AdminModel.isEmpty();
    }

    final json = doc.data() as Map<String, dynamic>;

    return AdminModel(
      id: doc.id,
      email: cast<String>(json['email']) ?? '',
      name: cast<String>(json['name']) ?? '',
      phoneNumber: cast<String>(json['phoneNumber']),
      photoUrl: cast<String>(json['photoUrl']),
      createdAt:
          (cast<Timestamp>(json['createdAt']) ?? Timestamp.now()).toDate(),
      lastLoginAt:
          (cast<Timestamp>(json['lastLoginAt']) ?? Timestamp.now()).toDate(),
      isActive: cast<bool>(json['isActive']) ?? false,
      permissions: List<String>.from(cast<List>(json['permissions']) ?? []),
    );
  }

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: cast<String>(json['id']) ?? '',
      email: cast<String>(json['email']) ?? '',
      name: cast<String>(json['name']) ?? '',
      phoneNumber: cast<String>(json['phoneNumber']),
      photoUrl: cast<String>(json['photoUrl']),
      createdAt:
          (cast<Timestamp>(json['createdAt']) ?? Timestamp.now()).toDate(),
      lastLoginAt:
          (cast<Timestamp>(json['lastLoginAt']) ?? Timestamp.now()).toDate(),
      isActive: cast<bool>(json['isActive']) ?? false,
      permissions: List<String>.from(cast<List>(json['permissions']) ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'isActive': isActive,
      'permissions': permissions,
    };
  }

  AdminModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
    List<String>? permissions,
  }) {
    return AdminModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      permissions: permissions ?? this.permissions,
    );
  }
}
