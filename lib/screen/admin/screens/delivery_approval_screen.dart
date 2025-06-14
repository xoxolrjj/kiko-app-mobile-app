import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kiko_app_mobile_app/core/models/delivery_model.dart';
import 'package:kiko_app_mobile_app/core/services/notification_service.dart';

class DeliveryApprovalScreen extends StatefulWidget {
  const DeliveryApprovalScreen({super.key});

  @override
  State<DeliveryApprovalScreen> createState() => _DeliveryApprovalScreenState();
}

class _DeliveryApprovalScreenState extends State<DeliveryApprovalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/admin'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Delivery Management'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'In Transit'),
            Tab(text: 'Delivered'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDeliveryList('pending'),
          _buildDeliveryList('in_transit'),
          _buildDeliveryList('delivered'),
        ],
      ),
    );
  }

  Widget _buildDeliveryList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('deliveries')
              .where('status', isEqualTo: status)
              .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final deliveries = snapshot.data?.docs ?? [];

        if (deliveries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_getStatusIcon(status), size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No ${status.replaceAll('_', ' ')} deliveries',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: deliveries.length,
          itemBuilder: (context, index) {
            final delivery = DeliveryModel.fromSnapshot(deliveries[index]);
            return _DeliveryCard(
              delivery: delivery,
              deliveryId: deliveries[index].id,
              onStatusUpdate:
                  (newStatus) =>
                      _updateDeliveryStatus(deliveries[index].id, newStatus),
            );
          },
        );
      },
    );
  }

  Future<void> _updateDeliveryStatus(String deliveryId, String status) async {
    try {
      // Update delivery status
      await FirebaseFirestore.instance
          .collection('deliveries')
          .doc(deliveryId)
          .update({
            'status': status,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Get the delivery document to find the associated order
      final deliveryDoc =
          await FirebaseFirestore.instance
              .collection('deliveries')
              .doc(deliveryId)
              .get();

      if (!deliveryDoc.exists) return;

      final deliveryData = deliveryDoc.data() as Map<String, dynamic>;
      final orderId = deliveryData['orderId'] as String;

      // Get order data for notifications
      final orderDoc =
          await FirebaseFirestore.instance
              .collection('orders')
              .doc(orderId)
              .get();

      if (!orderDoc.exists) return;

      final orderData = orderDoc.data() as Map<String, dynamic>;
      final notificationService = NotificationService();

      // Update the order status based on delivery status
      String orderStatus;
      switch (status) {
        case 'in_transit':
          orderStatus = 'shipped';
          break;
        case 'delivered':
          orderStatus = 'delivered';
          break;
        default:
          return;
      }

      // Update order status
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update(
        {'status': orderStatus, 'updatedAt': FieldValue.serverTimestamp()},
      );

      // Send notifications for admin-initiated status changes
      await notificationService.sendOrderStatusNotifications(
        orderId: orderId,
        newStatus: orderStatus,
        orderData: orderData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Delivery status updated to ${status.replaceAll('_', ' ')}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating delivery: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending_actions;
      case 'in_transit':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.done_all;
      default:
        return Icons.help;
    }
  }
}

class _DeliveryCard extends StatelessWidget {
  final DeliveryModel delivery;
  final String deliveryId;
  final Function(String) onStatusUpdate;

  const _DeliveryCard({
    required this.delivery,
    required this.deliveryId,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Order #${delivery.orderId}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatusChip(status: delivery.status),
              ],
            ),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.person,
              label: 'Customer',
              value: delivery.customerName,
            ),
            _InfoRow(
              icon: Icons.location_on,
              label: 'Address',
              value: delivery.deliveryAddress,
            ),
            // _InfoRow(
            //   icon: Icons.inventory,
            //   label: 'Items',
            //   value: '${delivery.items.length} items',
            // ),
            _InfoRow(
              icon: Icons.access_time,
              label: 'Created',
              value: _formatDate(delivery.createdAt),
            ),
            const SizedBox(height: 16),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    List<Widget> buttons = [];

    switch (delivery.status) {
      case 'pending':
        buttons = [
          ElevatedButton.icon(
            onPressed: () => onStatusUpdate('in_transit'),
            icon: const Icon(Icons.local_shipping),
            label: const Text('Mark as Shipped'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
        ];
        break;
      case 'in_transit':
        buttons = [
          ElevatedButton.icon(
            onPressed: () => onStatusUpdate('delivered'),
            icon: const Icon(Icons.done_all),
            label: const Text('Mark as Delivered'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ];
        break;
      default:
        buttons = [
          Text(
            'Delivery Complete',
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ];
    }

    return Row(mainAxisAlignment: MainAxisAlignment.end, children: buttons);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending_actions;
        break;
      case 'in_transit':
        color = Colors.blue;
        icon = Icons.local_shipping;
        break;
      case 'delivered':
        color = Colors.green;
        icon = Icons.done_all;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            status.replaceAll('_', ' ').toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
