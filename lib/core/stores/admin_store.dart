import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kiko_app_mobile_app/core/models/user_model.dart';
import 'package:kiko_app_mobile_app/dependency/dependency_manager.dart';
import 'package:mobx/mobx.dart';

part 'admin_store.g.dart';

class AdminStore = _AdminStore with _$AdminStore;

abstract class _AdminStore with Store {
  final FirebaseFirestore _firestore = sl<FirebaseFirestore>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  int totalUsers = 0;

  @observable
  int activeSellers = 0;

  @observable
  int pendingDeliveries = 0;

  @observable
  int unreadNotifications = 0;

  @observable
  ObservableList<UserModel> restrictedUsers = ObservableList<UserModel>();

  @computed
  bool get hasError => errorMessage != null;

  @action
  Future<void> loadDashboardData() async {
    try {
      isLoading = true;
      errorMessage = null;

      // Load all statistics in parallel
      await Future.wait([
        _loadUserStats(),
        _loadDeliveryStats(),
        _loadNotificationStats(),
        _loadRestrictedUsers(),
      ]);
    } catch (e) {
      errorMessage = 'Failed to load dashboard data: $e';
      debugPrint('Error loading dashboard data: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> _loadUserStats() async {
    try {
      // Total users
      final usersSnapshot = await _firestore.collection('users').get();
      totalUsers = usersSnapshot.docs.length;

      // Active sellers
      final sellersSnapshot =
          await _firestore
              .collection('users')
              .where('role', isEqualTo: UserRole.seller.name)
              .get();
      activeSellers = sellersSnapshot.docs.length;
    } catch (e) {
      debugPrint('Error loading user stats: $e');
    }
  }

  @action
  Future<void> _loadDeliveryStats() async {
    try {
      final pendingSnapshot =
          await _firestore
              .collection('deliveries')
              .where('status', isEqualTo: 'pending')
              .get();
      pendingDeliveries = pendingSnapshot.docs.length;
    } catch (e) {
      debugPrint('Error loading delivery stats: $e');
    }
  }

  @action
  Future<void> _loadNotificationStats() async {
    try {
      final notificationsSnapshot =
          await _firestore
              .collection('notifications')
              .where('type', whereIn: ['admin', 'system'])
              .where('isRead', isEqualTo: false)
              .get();
      unreadNotifications = notificationsSnapshot.docs.length;
    } catch (e) {
      debugPrint('Error loading notification stats: $e');
    }
  }

  @action
  Future<void> _loadRestrictedUsers() async {
    try {
      final restrictedSnapshot =
          await _firestore
              .collection('users')
              .where('status', whereIn: ['restricted', 'banned'])
              .get();

      final restrictedUsersList =
          restrictedSnapshot.docs
              .map((doc) => UserModel.fromSnapshot(doc))
              .toList();

      restrictedUsers.clear();
      restrictedUsers.addAll(restrictedUsersList);
    } catch (e) {
      debugPrint('Error loading restricted users: $e');
    }
  }

  @action
  Future<void> updateUserStatus(String userId, String status) async {
    try {
      isLoading = true;
      errorMessage = null;

      await _firestore.collection('users').doc(userId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Refresh the restricted users list
      await _loadRestrictedUsers();
      await _loadUserStats();
    } catch (e) {
      errorMessage = 'Failed to update user status: $e';
      debugPrint('Error updating user status: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> sendNotification({
    required String title,
    required String message,
    required String type,
    String? recipientType,
    String? recipientId,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;

      final notificationData = {
        'title': title,
        'message': message,
        'type': type,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      };

      if (recipientType != null) {
        notificationData['recipientType'] = recipientType;
      }

      if (recipientId != null) {
        notificationData['recipientId'] = recipientId;
      }

      await _firestore.collection('notifications').add(notificationData);

      // Refresh notification stats
      await _loadNotificationStats();
    } catch (e) {
      errorMessage = 'Failed to send notification: $e';
      debugPrint('Error sending notification: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> approveSellerRequest(
    String requestId,
    Map<String, dynamic> requestData,
  ) async {
    try {
      isLoading = true;
      errorMessage = null;

      await _firestore.runTransaction((transaction) async {
        // Update request status
        final requestRef = _firestore
            .collection('seller_requests')
            .doc(requestId);
        transaction.update(requestRef, {
          'status': 'approved',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Create seller profile
        final sellerRef = _firestore
            .collection('sellers')
            .doc(requestData['userId']);
        transaction.set(sellerRef, {
          'userId': requestData['userId'],
          'name': requestData['name'],
          'email': requestData['email'],
          'phone': requestData['phone'],
          'address': requestData['address'],
          'businessName': requestData['businessName'],
          'businessType': requestData['businessType'],
          'createdAt': FieldValue.serverTimestamp(),
          'status': 'active',
        });

        // Update user role
        final userRef = _firestore
            .collection('users')
            .doc(requestData['userId']);
        transaction.update(userRef, {
          'role': UserRole.seller.name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      // Refresh stats
      await _loadUserStats();
    } catch (e) {
      errorMessage = 'Failed to approve seller request: $e';
      debugPrint('Error approving seller request: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> rejectSellerRequest(String requestId) async {
    try {
      isLoading = true;
      errorMessage = null;

      await _firestore.collection('seller_requests').doc(requestId).update({
        'status': 'rejected',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      errorMessage = 'Failed to reject seller request: $e';
      debugPrint('Error rejecting seller request: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  void clearError() {
    errorMessage = null;
  }

  @action
  void dispose() {
    // Clean up any streams or subscriptions if needed
  }
}
