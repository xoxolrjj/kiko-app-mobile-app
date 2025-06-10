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
    final notificationRef = _firestore.collection('notifications').doc();
    await notificationRef.set({
      'id': notificationRef.id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
      'orderId': orderId,
      'sellerId': sellerId,
    });
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
