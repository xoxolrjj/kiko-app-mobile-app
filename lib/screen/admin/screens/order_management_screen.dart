import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiko_app_mobile_app/core/stores/notification_store.dart';
import 'package:kiko_app_mobile_app/core/models/notification_model.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      final orderRef = FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId);
      final orderDoc = await orderRef.get();
      final orderData = orderDoc.data() as Map<String, dynamic>;
      final notificationStore = NotificationStore();

      // Update order status and timestamp
      final updateData = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add status-specific timestamp
      if (status == 'shipped') {
        updateData['shippedAt'] = FieldValue.serverTimestamp();
      } else if (status == 'delivered') {
        updateData['deliveredAt'] = FieldValue.serverTimestamp();
      }

      await orderRef.update(updateData);

      // Send notification to buyer
      String title;
      String message;
      NotificationType type;

      switch (status) {
        case 'shipped':
          title = 'Order Shipped';
          message = 'Your order #${orderId.substring(0, 8)} has been shipped.';
          type = NotificationType.orderShipped;
          break;
        case 'delivered':
          title = 'Order Delivered';
          message =
              'Your order #${orderId.substring(0, 8)} has been delivered.';
          type = NotificationType.orderDelivered;
          break;
        default:
          return;
      }

      await notificationStore.createNotification(
        userId: orderData['buyerId'],
        title: title,
        message: message,
        type: type,
        orderId: orderId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to $status'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating order status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Management')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('orders')
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data?.docs ?? [];

          if (orders.isEmpty) {
            return const Center(child: Text('No orders found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              final orderId = orders[index].id;
              final status = order['status'] as String;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${orderId.substring(0, 8)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Buyer: ${order['buyerName']}'),
                      Text('Product: ${order['productName']}'),
                      Text('Quantity: ${order['quantity']} sacks'),
                      Text(
                        'Total: ₱${order['totalAmount'].toStringAsFixed(2)}',
                      ),
                      Text('Status: ${status.toUpperCase()}'),
                      const SizedBox(height: 16),
                      if (status == 'ready')
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    () =>
                                        _updateOrderStatus(orderId, 'shipped'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Mark as Shipped'),
                              ),
                            ),
                          ],
                        )
                      else if (status == 'shipped')
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    () => _updateOrderStatus(
                                      orderId,
                                      'delivered',
                                    ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Mark as Delivered'),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
