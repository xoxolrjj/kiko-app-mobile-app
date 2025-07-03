import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiko_app_mobile_app/core/models/notification_model.dart';

class NotificationStore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    String? orderId,
    String? sellerId,
  }) async {
    try {
      final notificationRef = _firestore.collection('notifications').doc();

      // Add debug logging for admin reply notifications
      if (type == NotificationType.adminReply) {
        print('🔔 Creating admin reply notification for seller: $userId');
        print('📧 Title: $title');
        print('💬 Message: $message');
      }

      await notificationRef.set({
        'id': notificationRef.id,
        'userId': userId,
        'title': title,
        'message': message,
        'type': type.toString().split('.').last,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'orderId': orderId,
        'sellerId': sellerId,
      });

      // Success logging for admin reply notifications
      if (type == NotificationType.adminReply) {
        print(
          '✅ Admin reply notification created successfully for seller: $userId',
        );
      }
    } catch (e) {
      print('❌ Error creating notification for user $userId: $e');
      if (type == NotificationType.adminReply) {
        print(
          '❌ Failed to create admin reply notification for seller: $userId',
        );
      }
      rethrow;
    }
  }

  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => NotificationModel.fromSnapshot(doc))
                  .toList(),
        );
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();
    final notifications =
        await _firestore
            .collection('notifications')
            .where('userId', isEqualTo: userId)
            .where('isRead', isEqualTo: false)
            .get();

    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  Future<int> getUnreadCount(String userId) async {
    final snapshot =
        await _firestore
            .collection('notifications')
            .where('userId', isEqualTo: userId)
            .where('isRead', isEqualTo: false)
            .count()
            .get();
    return snapshot.count ?? 0;
  }
}
