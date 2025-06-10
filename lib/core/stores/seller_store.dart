import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:kiko_app_mobile_app/core/models/seller_model.dart';
import 'package:kiko_app_mobile_app/core/models/seller_verification_request_model.dart';
import 'package:kiko_app_mobile_app/core/models/user_model.dart';
import 'package:mobx/mobx.dart';
import 'package:kiko_app_mobile_app/dependency/dependency_manager.dart';

part 'seller_store.g.dart';

class SellerStore = _SellerStore with _$SellerStore;

abstract class _SellerStore with Store {
  final FirebaseFirestore _firestore = sl<FirebaseFirestore>();
  final FirebaseAuth _auth = sl<FirebaseAuth>();
  final FirebaseStorage _storage = sl<FirebaseStorage>();
  final LocalAuthentication _localAuth = LocalAuthentication();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  int sellerCount = 0;

  // Commented out for now - biometric verification
  // @observable
  // bool biometricCheckAvailable = false;

  // Temporary property for when biometric verification is disabled
  @observable
  bool biometricCheckAvailable = true; // Always true when biometric is disabled

  // @observable
  // bool biometricAuthenticated = false;

  // Temporary property for when biometric verification is disabled
  @observable
  bool biometricAuthenticated = false;

  // @observable
  // List<BiometricType> availableBiometrics = [];

  // Temporary property for when biometric verification is disabled
  @observable
  List<BiometricType> availableBiometrics = [];

  // @action
  // Future<void> initializeBiometrics() async {
  //   try {
  //     // Check if device supports biometrics
  //     biometricCheckAvailable = await _localAuth.canCheckBiometrics;
  //
  //     if (biometricCheckAvailable) {
  //       availableBiometrics = await _localAuth.getAvailableBiometrics();
  //     }
  //   } catch (e) {
  //     debugPrint('Error initializing biometrics: $e');
  //     errorMessage = 'Failed to initialize biometric authentication';
  //   }
  // }

  // @action
  // Future<bool> authenticateWithBiometrics() async {
  //   try {
  //     if (!biometricCheckAvailable) {
  //       errorMessage = 'Biometric authentication not available on this device';
  //       return false;
  //     }

  //     final isAuthenticated = await _localAuth.authenticate(
  //       localizedReason: 'Verify your identity for seller account registration',
  //       options: const AuthenticationOptions(
  //         biometricOnly: true,
  //         stickyAuth: true,
  //       ),
  //     );

  //     biometricAuthenticated = isAuthenticated;
  //
  //     if (!isAuthenticated) {
  //       errorMessage = 'Biometric authentication failed';
  //     }
  //
  //     return isAuthenticated;
  //   } catch (e) {
  //     debugPrint('Error during biometric authentication: $e');
  //     errorMessage = 'Biometric authentication error: $e';
  //     return false;
  //   }
  // }

  // Temporary method for when biometric verification is disabled
  @action
  Future<void> initializeBiometrics() async {
    // Do nothing - biometric verification is disabled
    biometricCheckAvailable = true;
  }

  // Temporary method for when biometric verification is disabled
  @action
  Future<bool> authenticateWithBiometrics() async {
    // Always return true when biometric verification is disabled
    biometricAuthenticated = true;
    return true;
  }

  @action
  Future<void> loadSellerCount() async {
    try {
      final querySnapshot =
          await _firestore
              .collection('users')
              .where('role', isEqualTo: UserRole.seller.name)
              .get();

      sellerCount = querySnapshot.docs.length;
      debugPrint('Loaded seller count: $sellerCount');
    } catch (e) {
      debugPrint('Error loading seller count: $e');
      errorMessage = 'Failed to load seller count';
    }
  }

  @action
  void incrementSellerCount() {
    sellerCount++;
  }

  @action
  void decrementSellerCount() {
    if (sellerCount > 0) {
      sellerCount--;
    }
  }

  @action
  void setupSellerCountListener() {
    _firestore
        .collection('users')
        .where('role', isEqualTo: UserRole.seller.name)
        .snapshots()
        .listen((snapshot) {
          sellerCount = snapshot.docs.length;
          debugPrint('Seller count updated: $sellerCount');
        })
        .onError((error) {
          debugPrint('Error in seller count listener: $error');
          errorMessage = 'Failed to track seller count updates';
        });
  }

  @action
  Future<void> submitSellerVerificationRequest({
    required String businessName,
    required String businessType,
    required String shopName,
    required String contactNumber,
    required String shopLocation,
    required String businessAddress,
    required PhilippineIDType idType,
    required String idNumber,
    required String idImagePath,
    required String faceImagePath,
    required UserModel currentUser,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;

      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Commented out for now - biometric verification
      // First, verify biometric authentication
      // final biometricVerified = await authenticateWithBiometrics();
      // if (!biometricVerified) {
      //   throw Exception('Biometric verification required');
      // }
      final biometricVerified = true; // Skip biometric verification for now

      // Upload ID verification image
      final idRef = _storage.ref(
        'seller_verifications/$userId/id_verification_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await idRef.putFile(File(idImagePath));
      final idImageUrl = await idRef.getDownloadURL();

      // Upload face verification image
      final faceRef = _storage.ref(
        'seller_verifications/$userId/face_verification_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await faceRef.putFile(File(faceImagePath));
      final faceImageUrl = await faceRef.getDownloadURL();

      // Create biometric data hash (simplified - in production use proper encryption)
      final biometricData = _generateBiometricHash(
        userId,
        DateTime.now().toIso8601String(),
      );

      // Create verification request
      final verificationRequest = SellerVerificationRequest(
        id: '', // Will be set by Firestore
        userId: userId,
        userName: currentUser.name,
        userEmail: currentUser.email,
        userPhone: currentUser.phoneNumber ?? '',

        shopName: shopName,
        contactNumber: contactNumber,
        shopLocation: shopLocation,

        idType: idType,
        idNumber: idNumber,
        idImageUrl: idImageUrl,
        faceVerificationUrl: faceImageUrl,
        biometricVerified: true,
        biometricData: biometricData,
        status: VerificationStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Submit to Firestore for admin review
      await _firestore
          .collection('seller_verification_requests')
          .add(verificationRequest.toJson());

      debugPrint('Seller verification request submitted successfully');
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('Error submitting seller verification: $e');
    } finally {
      isLoading = false;
    }
  }

  String _generateBiometricHash(String userId, String timestamp) {
    // Simple hash generation - in production, use proper cryptographic methods
    final data = '$userId-$timestamp-${DateTime.now().millisecondsSinceEpoch}';
    final bytes = utf8.encode(data);
    return base64Encode(bytes);
  }

  @action
  Future<SellerVerificationRequest?> getVerificationStatus(
    String userId,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('seller_verification_requests')
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return SellerVerificationRequest.fromSnapshot(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting verification status: $e');
      return null;
    }
  }

  @action
  void clearError() {
    errorMessage = null;
  }

  // Legacy method - kept for backward compatibility
  @action
  Future<void> registerSeller({
    required String shopName,
    required String contactNumber,
    required String shopLocation,
    required String idImagePath,
    required String faceImagePath,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;

      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Upload ID verification image
      final idRef = _storage.ref(
        'seller_verifications/$userId/id_verification.jpg',
      );
      await idRef.putFile(File(idImagePath));
      final idVerificationUrl = await idRef.getDownloadURL();

      // Upload face verification image
      final faceRef = _storage.ref(
        'seller_verifications/$userId/face_verification.jpg',
      );
      await faceRef.putFile(File(faceImagePath));
      final faceVerificationUrl = await faceRef.getDownloadURL();

      // Create seller document
      final seller = SellerModel(
        id: userId,
        userId: userId,
        shopName: shopName,
        contactNumber: contactNumber,
        shopLocation: shopLocation,
        idVerificationUrl: idVerificationUrl,
        faceVerificationUrl: faceVerificationUrl,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('sellers').doc(userId).set(seller.toJson());
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }
}
