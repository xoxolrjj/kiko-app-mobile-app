import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiko_app_mobile_app/core/models/notification_model.dart';
import 'package:kiko_app_mobile_app/core/stores/notification_store.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationStore _notificationStore = NotificationStore();

  /// Send notifications for order status changes
  Future<void> sendOrderStatusNotifications({
    required String orderId,
    required String newStatus,
    required Map<String, dynamic> orderData,
  }) async {
    try {
      final buyerId = orderData['buyerId'] as String;
      final sellerId = orderData['sellerId'] as String;
      final buyerName = orderData['buyerName'] as String? ?? 'Customer';
      final sellerName = orderData['sellerName'] as String? ?? 'Seller';

      switch (newStatus) {
        case 'pending':
          await _sendPendingNotifications(
            orderId,
            buyerId,
            sellerId,
            buyerName,
          );
          break;
        case 'accepted':
          await _sendAcceptedNotifications(orderId, buyerId, sellerName);
          break;
        case 'preparing':
          await _sendPreparingNotifications(orderId, buyerId, sellerName);
          break;
        case 'shipped':
          await _sendShippedNotifications(
            orderId,
            buyerId,
            sellerId,
            buyerName,
            sellerName,
          );
          break;
        case 'delivered':
          await _sendDeliveredNotifications(
            orderId,
            buyerId,
            sellerId,
            buyerName,
            sellerName,
          );
          break;
        case 'cancelled':
          await _sendCancelledNotifications(
            orderId,
            buyerId,
            sellerId,
            buyerName,
            sellerName,
          );
          break;
      }
    } catch (e) {
      print('Error sending order status notifications: $e');
    }
  }

  /// Send notification when order is placed (pending status)
  Future<void> _sendPendingNotifications(
    String orderId,
    String buyerId,
    String sellerId,
    String buyerName,
  ) async {
    // Notify buyer that order is pending
    await _notificationStore.createNotification(
      userId: buyerId,
      title: 'Order Placed Successfully',
      message:
          'Your order #${orderId.substring(0, 8)} is pending approval from the seller.',
      type: NotificationType.orderPlaced,
      orderId: orderId,
    );

    // Notify seller of new order
    await _notificationStore.createNotification(
      userId: sellerId,
      title: 'New Order Received',
      message:
          'You have a new order #${orderId.substring(0, 8)} from $buyerName.',
      type: NotificationType.newOrder,
      orderId: orderId,
    );
  }

  /// Send notification when order is accepted
  Future<void> _sendAcceptedNotifications(
    String orderId,
    String buyerId,
    String sellerName,
  ) async {
    await _notificationStore.createNotification(
      userId: buyerId,
      title: 'Order Accepted',
      message:
          'Great news! Your order #${orderId.substring(0, 8)} has been accepted by $sellerName.',
      type: NotificationType.orderAccepted,
      orderId: orderId,
    );
  }

  /// Send notification when order is being prepared
  Future<void> _sendPreparingNotifications(
    String orderId,
    String buyerId,
    String sellerName,
  ) async {
    await _notificationStore.createNotification(
      userId: buyerId,
      title: 'Order Being Prepared',
      message:
          '$sellerName is now preparing your order #${orderId.substring(0, 8)}.',
      type: NotificationType.orderPreparing,
      orderId: orderId,
    );
  }

  /// Send notifications when order is shipped
  Future<void> _sendShippedNotifications(
    String orderId,
    String buyerId,
    String sellerId,
    String buyerName,
    String sellerName,
  ) async {
    // Notify buyer
    await _notificationStore.createNotification(
      userId: buyerId,
      title: 'Order Shipped',
      message:
          'Your order #${orderId.substring(0, 8)} has been shipped and is on its way!',
      type: NotificationType.orderShipped,
      orderId: orderId,
    );

    // Notify seller
    await _notificationStore.createNotification(
      userId: sellerId,
      title: 'Order Shipped',
      message:
          'Order #${orderId.substring(0, 8)} for $buyerName has been shipped.',
      type: NotificationType.orderShipped,
      orderId: orderId,
    );

    // Notify all admins
    await _sendNotificationToAllAdmins(
      title: 'Order Shipped',
      message:
          'Order #${orderId.substring(0, 8)} from $sellerName to $buyerName has been shipped.',
      type: NotificationType.orderShipped,
      orderId: orderId,
    );
  }

  /// Send notifications when order is delivered
  Future<void> _sendDeliveredNotifications(
    String orderId,
    String buyerId,
    String sellerId,
    String buyerName,
    String sellerName,
  ) async {
    // Notify buyer
    await _notificationStore.createNotification(
      userId: buyerId,
      title: 'Order Delivered',
      message:
          'Your order #${orderId.substring(0, 8)} has been delivered successfully!',
      type: NotificationType.orderDelivered,
      orderId: orderId,
    );

    // Notify seller
    await _notificationStore.createNotification(
      userId: sellerId,
      title: 'Order Delivered',
      message:
          'Order #${orderId.substring(0, 8)} for $buyerName has been delivered successfully.',
      type: NotificationType.orderDelivered,
      orderId: orderId,
    );

    // Notify all admins
    await _sendNotificationToAllAdmins(
      title: 'Order Delivered',
      message:
          'Order #${orderId.substring(0, 8)} from $sellerName to $buyerName has been delivered.',
      type: NotificationType.orderDelivered,
      orderId: orderId,
    );
  }

  /// Send notifications when order is cancelled
  Future<void> _sendCancelledNotifications(
    String orderId,
    String buyerId,
    String sellerId,
    String buyerName,
    String sellerName,
  ) async {
    // Notify buyer
    await _notificationStore.createNotification(
      userId: buyerId,
      title: 'Order Cancelled',
      message: 'Your order #${orderId.substring(0, 8)} has been cancelled.',
      type: NotificationType.orderCancelled,
      orderId: orderId,
    );

    // Notify seller
    await _notificationStore.createNotification(
      userId: sellerId,
      title: 'Order Cancelled',
      message:
          'Order #${orderId.substring(0, 8)} for $buyerName has been cancelled.',
      type: NotificationType.orderCancelled,
      orderId: orderId,
    );

    // Notify all admins
    await _sendNotificationToAllAdmins(
      title: 'Order Cancelled',
      message:
          'Order #${orderId.substring(0, 8)} from $sellerName to $buyerName has been cancelled.',
      type: NotificationType.orderCancelled,
      orderId: orderId,
    );
  }

  /// Send notification to all admin users
  Future<void> _sendNotificationToAllAdmins({
    required String title,
    required String message,
    required NotificationType type,
    String? orderId,
    String? sellerId,
  }) async {
    try {
      final adminSnapshot = await _firestore.collection('admins').get();

      for (final adminDoc in adminSnapshot.docs) {
        await _notificationStore.createNotification(
          userId: adminDoc.id,
          title: title,
          message: message,
          type: type,
          orderId: orderId,
          sellerId: sellerId,
        );
      }
    } catch (e) {
      print('Error sending notifications to admins: $e');
    }
  }
}
