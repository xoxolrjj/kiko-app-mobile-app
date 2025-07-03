import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kiko_app_mobile_app/core/models/apology_message_model.dart';
import 'package:kiko_app_mobile_app/core/models/notification_model.dart';
import 'package:kiko_app_mobile_app/core/stores/notification_store.dart';
import 'package:kiko_app_mobile_app/dependency/dependency_manager.dart';
import 'package:mobx/mobx.dart';

part 'apology_store.g.dart';

class ApologyStore = _ApologyStore with _$ApologyStore;

abstract class _ApologyStore with Store {
  final FirebaseFirestore _firestore = sl<FirebaseFirestore>();
  final NotificationStore _notificationStore = NotificationStore();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  ObservableList<ApologyMessageModel> apologyMessages =
      ObservableList<ApologyMessageModel>();

  @computed
  bool get hasError => errorMessage != null;

  @action
  Future<void> sendApologyMessage({
    required String sellerId,
    required String sellerName,
    required String sellerEmail,
    required String message,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;

      final apologyRef = _firestore.collection('apology_messages').doc();
      final apologyMessage = ApologyMessageModel(
        id: apologyRef.id,
        sellerId: sellerId,
        sellerName: sellerName,
        sellerEmail: sellerEmail,
        message: message,
        status: ApologyStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await apologyRef.set(apologyMessage.toFirestore());

      await _notifyAdmins(apologyMessage);

      debugPrint('Apology message sent successfully');
    } catch (e) {
      errorMessage = 'Failed to send apology message: $e';
      debugPrint('Error sending apology message: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> loadApologyMessages() async {
    try {
      isLoading = true;
      errorMessage = null;

      final snapshot =
          await _firestore
              .collection('apology_messages')
              .orderBy('createdAt', descending: true)
              .get();

      final messages =
          snapshot.docs
              .map((doc) => ApologyMessageModel.fromSnapshot(doc))
              .toList();

      apologyMessages.clear();
      apologyMessages.addAll(messages);
    } catch (e) {
      errorMessage = 'Failed to load apology messages: $e';
      debugPrint('Error loading apology messages: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> loadSellerApologyMessages(String sellerId) async {
    try {
      isLoading = true;
      errorMessage = null;

      final snapshot =
          await _firestore
              .collection('apology_messages')
              .where('sellerId', isEqualTo: sellerId)
              .orderBy('createdAt', descending: true)
              .get();

      final messages =
          snapshot.docs
              .map((doc) => ApologyMessageModel.fromSnapshot(doc))
              .toList();

      apologyMessages.clear();
      apologyMessages.addAll(messages);
    } catch (e) {
      errorMessage = 'Failed to load seller apology messages: $e';
      debugPrint('Error loading seller apology messages: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> respondToApology({
    required String apologyId,
    required String adminResponse,
    required String reviewedBy,
    required ApologyStatus status,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;

      await _firestore.collection('apology_messages').doc(apologyId).update({
        'adminResponse': adminResponse,
        'reviewedBy': reviewedBy,
        'reviewedAt': FieldValue.serverTimestamp(),
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await loadApologyMessages();

      debugPrint('Apology response sent successfully');
    } catch (e) {
      errorMessage = 'Failed to respond to apology: $e';
      debugPrint('Error responding to apology: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> _notifyAdmins(ApologyMessageModel apologyMessage) async {
    try {
      final adminSnapshot = await _firestore.collection('admins').get();

      for (final adminDoc in adminSnapshot.docs) {
        await _notificationStore.createNotification(
          userId: adminDoc.id,
          title: 'New Apology Message',
          message:
              'Seller ${apologyMessage.sellerName} has sent an apology message: "${apologyMessage.message.length > 50 ? apologyMessage.message.substring(0, 50) + '...' : apologyMessage.message}"',
          type: NotificationType.sellerApology,
          sellerId: apologyMessage.sellerId,
        );
      }
    } catch (e) {
      debugPrint('Error notifying admins about apology: $e');
    }
  }

  @action
  Stream<List<ApologyMessageModel>> getApologyMessagesStream() {
    return _firestore
        .collection('apology_messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ApologyMessageModel.fromSnapshot(doc))
                  .toList(),
        );
  }

  @action
  Stream<List<ApologyMessageModel>> getSellerApologyMessagesStream(
    String sellerId,
  ) {
    return _firestore
        .collection('apology_messages')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ApologyMessageModel.fromSnapshot(doc))
                  .toList(),
        );
  }

  @action
  void clearError() {
    errorMessage = null;
  }
}
