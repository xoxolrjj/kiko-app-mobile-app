import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kiko_app_mobile_app/core/models/seller_model.dart';
import 'package:kiko_app_mobile_app/core/models/seller_verification_request_model.dart';
import 'package:kiko_app_mobile_app/core/models/user_model.dart';
import 'package:kiko_app_mobile_app/core/stores/notification_store.dart';
import 'package:kiko_app_mobile_app/core/models/notification_model.dart';
import 'package:mobx/mobx.dart';
import 'package:kiko_app_mobile_app/dependency/dependency_manager.dart';

part 'seller_store.g.dart';

class SellerStore = _SellerStore with _$SellerStore;

abstract class _SellerStore with Store {
  final FirebaseFirestore _firestore = sl<FirebaseFirestore>();
  final FirebaseAuth _auth = sl<FirebaseAuth>();
  final FirebaseStorage _storage = sl<FirebaseStorage>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  int sellerCount = 0;

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
    _firestore.collection('sellers').snapshots().listen((snapshot) {
      sellerCount = snapshot.docs.length;
    });
  }

  @action
  Future<void> loadSellerCount() async {
    try {
      final snapshot = await _firestore.collection('sellers').get();
      sellerCount = snapshot.docs.length;
    } catch (e) {
      debugPrint('Error loading seller count: $e');
    }
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
        status: VerificationStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Submit to Firestore for admin review
      await _firestore
          .collection('seller_verification_requests')
          .add(verificationRequest.toJson());

      // Create notification for the user
      final notificationStore = NotificationStore();
      await notificationStore.createNotification(
        userId: userId,
        title: 'Application Submitted',
        message:
            'Your seller application is being processed. We will review your application and notify you once it\'s approved or if additional information is needed.',
        type: NotificationType.sellerApproval,
      );

      debugPrint('Seller verification request submitted successfully');
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('Error submitting seller verification: $e');
    } finally {
      isLoading = false;
    }
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
