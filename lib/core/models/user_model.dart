import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiko_app_mobile_app/core/commons/utils.dart';

part 'user_model.freezed.dart';

enum UserRole { user, seller }

@freezed
class UserModel with _$UserModel {
  factory UserModel({
    required String id,
    required String email,
    required String name,
    required String location,
    required String password,
    String? phoneNumber,
    String? gender,
    int? age,
    String? photoUrl,
    required UserRole role,
    bool? isVerified,
    @Default(false) bool isRestricted,
    required DateTime createdAt,
  }) = _UserModel;

  UserModel._();

  factory UserModel.isEmpty() {
    return UserModel(
      id: '',
      email: '',
      name: '',
      location: '',
      phoneNumber: null,
      gender: null,
      age: null,
      photoUrl: null,
      role: UserRole.user,
      isVerified: false,
      isRestricted: false,
      password: '',
      createdAt: DateTime.now(),
    );
  }

  factory UserModel.fromSnapshot(DocumentSnapshot doc) {
    if (doc.data() == null) {
      return UserModel.isEmpty();
    }

    final json = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      password: cast<String>(json['password']) ?? '',
      email: cast<String>(json['email']) ?? '',
      name: cast<String>(json['name']) ?? '',
      location: cast<String>(json['location']) ?? '',
      phoneNumber: cast<String>(json['phoneNumber']) ?? '',
      gender: cast<String>(json['gender']) ?? '',
      age: cast<int>(json['age']) ?? 0,
      photoUrl: cast<String>(json['photoUrl']) ?? '',
      role:
          UserRole.values.byName(cast<String>(json['role']) ?? '') ??
          UserRole.user,
      isVerified: cast<bool>(json['isVerified']) ?? false,
      isRestricted: cast<bool>(json['isRestricted']) ?? false,
      createdAt:
          (cast<Timestamp>(json['createdAt']) ?? Timestamp.now()).toDate(),
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      password: cast<String>(json['password']) ?? '',
      id: cast<String>(json['id']) ?? '',
      email: cast<String>(json['email']) ?? '',
      name: cast<String>(json['name']) ?? '',
      location: cast<String>(json['location']) ?? '',
      phoneNumber: cast<String>(json['phoneNumber']) ?? '',
      gender: cast<String>(json['gender']) ?? '',
      age: cast<int>(json['age']) ?? 0,
      photoUrl: cast<String>(json['photoUrl']) ?? '',
      role:
          UserRole.values.byName(cast<String>(json['role']) ?? '') ??
          UserRole.user,
      isVerified: cast<bool>(json['isVerified']) ?? false,
      isRestricted: cast<bool>(json['isRestricted']) ?? false,
      createdAt:
          (cast<Timestamp>(json['createdAt']) ?? Timestamp.now()).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'password': password,
      'email': email,
      'name': name,
      'location': location,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'age': age,
      'photoUrl': photoUrl,
      'role': role.name,
      'isVerified': isVerified,
      'isRestricted': isRestricted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
