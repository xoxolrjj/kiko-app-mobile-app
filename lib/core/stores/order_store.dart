import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiko_app_mobile_app/core/models/order_model.dart';
import 'package:kiko_app_mobile_app/core/stores/notification_store.dart';
import 'package:kiko_app_mobile_app/core/models/notification_model.dart';
import 'package:kiko_app_mobile_app/core/services/notification_service.dart';

class OrderStore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationStore _notificationStore = NotificationStore();
  final NotificationService _notificationService = NotificationService();

  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      // Get the order document
      final orderRef = _firestore.collection('orders').doc(orderId);
      final orderDoc = await orderRef.get();

      if (!orderDoc.exists) {
        throw Exception('Order not found');
      }

      final orderData = orderDoc.data() as Map<String, dynamic>;
      final currentStatus = OrderStatus.values.firstWhere(
        (e) => e.name == orderData['status'],
        orElse: () => OrderStatus.pending,
      );

      // Check if order can be cancelled
      if (currentStatus == OrderStatus.delivered ||
          currentStatus == OrderStatus.cancelled) {
        throw Exception('Order cannot be cancelled in its current state');
      }

      // Update order status
      await orderRef.update({
        'status': OrderStatus.cancelled.name,
        'updatedAt': FieldValue.serverTimestamp(),
        'rejectionReason': reason,
      });

      // Send comprehensive notifications using notification service
      await _notificationService.sendOrderStatusNotifications(
        orderId: orderId,
        newStatus: 'cancelled',
        orderData: orderData,
      );
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('orders')
              .where('buyerId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user orders: $e');
    }
  }

  Future<List<OrderModel>> getSellerOrders(String sellerId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('orders')
              .where('sellerId', isEqualTo: sellerId)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch seller orders: $e');
    }
  }
}
