import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiko_app_mobile_app/core/stores/auth_store.dart';
import 'package:cached_network_image/cached_network_image.dart';

enum OrderStatus {
  pending,
  accepted,
  preparing,
  ready,
  shipped,
  delivered,
  cancelled,
}

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? sellerId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    final authStore = Provider.of<AuthStore>(context, listen: false);
    sellerId = authStore.currentUser?.id;
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
          onPressed: () => context.go('/profile'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Order Requests'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Pending', icon: Icon(Icons.pending_actions)),
            Tab(text: 'Accepted', icon: Icon(Icons.check_circle)),
            Tab(text: 'Preparing', icon: Icon(Icons.kitchen)),
            Tab(text: 'Ready', icon: Icon(Icons.done)),
            Tab(text: 'Shipped', icon: Icon(Icons.local_shipping)),
            Tab(text: 'Delivered', icon: Icon(Icons.done_all)),
            Tab(text: 'Cancelled', icon: Icon(Icons.cancel)),
          ],
        ),
      ),
      body:
          sellerId == null
              ? const Center(child: Text('Please log in to view orders'))
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildOrdersList(OrderStatus.pending),
                  _buildOrdersList(OrderStatus.accepted),
                  _buildOrdersList(OrderStatus.preparing),
                  _buildOrdersList(OrderStatus.ready),
                  _buildOrdersList(OrderStatus.shipped),
                  _buildOrdersList(OrderStatus.delivered),
                  _buildOrdersList(OrderStatus.cancelled),
                ],
              ),
    );
  }

  Widget _buildOrdersList(OrderStatus status) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('orders')
              .where('sellerId', isEqualTo: sellerId)
              .where('status', isEqualTo: status.name)
              .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data?.docs ?? [];

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getStatusIcon(status),
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No ${status.name} orders',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  _getEmptyMessage(status),
                  style: TextStyle(color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final orderData = orders[index].data() as Map<String, dynamic>;
            return _OrderCard(
              orderId: orders[index].id,
              orderData: orderData,
              status: status,
              onStatusUpdate:
                  (newStatus) =>
                      _updateOrderStatus(orders[index].id, newStatus),
            );
          },
        );
      },
    );
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.pending_actions;
      case OrderStatus.accepted:
        return Icons.check_circle;
      case OrderStatus.preparing:
        return Icons.kitchen;
      case OrderStatus.ready:
        return Icons.done;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getEmptyMessage(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'No new orders waiting for your response';
      case OrderStatus.accepted:
        return 'No accepted orders to prepare';
      case OrderStatus.preparing:
        return 'No orders currently being prepared';
      case OrderStatus.ready:
        return 'No orders ready for pickup/delivery';
      case OrderStatus.shipped:
        return 'No orders shipped yet';
      case OrderStatus.delivered:
        return 'No orders delivered yet';
      case OrderStatus.cancelled:
        return 'No cancelled orders';
    }
  }

  Future<void> _updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      Map<String, dynamic> updateData = {
        'status': newStatus.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add timestamp for specific status changes
      switch (newStatus) {
        case OrderStatus.accepted:
          updateData['acceptedAt'] = FieldValue.serverTimestamp();
          // Create delivery record for admin approval when order is accepted
          await _createDeliveryRecord(orderId);
          break;
        case OrderStatus.ready:
          updateData['readyAt'] = FieldValue.serverTimestamp();
          break;
        case OrderStatus.shipped:
          updateData['shippedAt'] = FieldValue.serverTimestamp();
          break;
        case OrderStatus.delivered:
          updateData['deliveredAt'] = FieldValue.serverTimestamp();
          break;
        default:
          break;
      }

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update(updateData);

      // If marking as delivered, update the delivery record
      if (newStatus == OrderStatus.delivered) {
        final deliveryQuery =
            await FirebaseFirestore.instance
                .collection('deliveries')
                .where('orderId', isEqualTo: orderId)
                .limit(1)
                .get();

        if (deliveryQuery.docs.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('deliveries')
              .doc(deliveryQuery.docs.first.id)
              .update({
                'status': 'delivered',
                'updatedAt': FieldValue.serverTimestamp(),
              });
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to ${newStatus.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createDeliveryRecord(String orderId) async {
    try {
      final orderDoc =
          await FirebaseFirestore.instance
              .collection('orders')
              .doc(orderId)
              .get();

      if (!orderDoc.exists) return;

      final orderData = orderDoc.data() as Map<String, dynamic>;

      // Check if delivery record already exists
      final existingDeliveryQuery =
          await FirebaseFirestore.instance
              .collection('deliveries')
              .where('orderId', isEqualTo: orderId)
              .limit(1)
              .get();

      if (existingDeliveryQuery.docs.isNotEmpty) return;

      // Convert order items to delivery items format
      final orderItems = (orderData['items'] as List<dynamic>?) ?? [];
      final deliveryItems =
          orderItems.map((item) {
            final itemData = item as Map<String, dynamic>;
            return {
              'productId': itemData['productId'] ?? '',
              'productName': itemData['productName'] ?? '',
              'quantity': itemData['quantity'] ?? 0,
              'price':
                  itemData['pricePerUnit'] ?? 0.0, // Use pricePerUnit as price
            };
          }).toList();

      // Create delivery record
      await FirebaseFirestore.instance.collection('deliveries').add({
        'orderId': orderId,
        'customerId': orderData['buyerId'],
        'customerName': orderData['buyerName'],
        'deliveryAddress': orderData['deliveryAddress'],
        'items': deliveryItems,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating delivery record: $e');
    }
  }
}

class _OrderCard extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;
  final OrderStatus status;
  final Function(OrderStatus) onStatusUpdate;

  const _OrderCard({
    required this.orderId,
    required this.orderData,
    required this.status,
    required this.onStatusUpdate,
  });

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.pending_actions;
      case OrderStatus.accepted:
        return Icons.check_circle;
      case OrderStatus.preparing:
        return Icons.kitchen;
      case OrderStatus.ready:
        return Icons.done;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = (orderData['items'] as List<dynamic>?) ?? [];
    final totalAmount = (orderData['totalAmount'] as num?)?.toDouble() ?? 0.0;
    final buyerName = orderData['buyerName'] as String? ?? 'Unknown Customer';
    final buyerPhone = orderData['buyerPhone'] as String? ?? '';
    final deliveryAddress = orderData['deliveryAddress'] as String? ?? '';

    // Helper function to parse DateTime from either String or Timestamp
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return null;
    }

    final createdAt = parseDateTime(orderData['createdAt']);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(status),
          child: Icon(_getStatusIcon(status), color: Colors.white),
        ),
        title: Text(
          'Order #${orderId.substring(0, 8)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: $buyerName'),
            Text('Total: ₱${totalAmount.toStringAsFixed(2)}'),
            if (createdAt != null) Text('Date: ${_formatDate(createdAt)}'),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Information
                _buildSectionTitle('Customer Information'),
                const SizedBox(height: 8),
                _InfoRow(icon: Icons.person, label: 'Name', value: buyerName),
                if (buyerPhone.isNotEmpty)
                  _InfoRow(
                    icon: Icons.phone,
                    label: 'Phone',
                    value: buyerPhone,
                  ),
                if (deliveryAddress.isNotEmpty)
                  _InfoRow(
                    icon: Icons.location_on,
                    label: 'Address',
                    value: deliveryAddress,
                  ),

                const SizedBox(height: 16),

                // Order Items
                _buildSectionTitle('Order Items'),
                const SizedBox(height: 8),
                ...items.map((item) => _buildOrderItem(item)).toList(),

                const SizedBox(height: 16),

                // Total
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₱${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Action Buttons
                _buildActionButtons(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildOrderItem(dynamic item) {
    final productName = item['productName'] as String? ?? 'Unknown Product';
    final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
    final pricePerUnit = (item['pricePerUnit'] as num?)?.toDouble() ?? 0.0;
    final totalPrice = (item['totalPrice'] as num?)?.toDouble() ?? 0.0;
    final productImage = item['productImage'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 50,
              height: 50,
              child:
                  productImage.isNotEmpty
                      ? CachedNetworkImage(
                        imageUrl: productImage,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image_not_supported),
                            ),
                      )
                      : Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image),
                      ),
            ),
          ),
          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: $quantity × ₱${pricePerUnit.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),

          // Total Price
          Text(
            '₱${totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    List<Widget> buttons = [];

    switch (status) {
      case OrderStatus.pending:
        buttons = [
          Expanded(
            child: OutlinedButton(
              onPressed: () => onStatusUpdate(OrderStatus.cancelled),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text('Decline'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => onStatusUpdate(OrderStatus.accepted),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Accept'),
            ),
          ),
        ];
        break;
      case OrderStatus.accepted:
        buttons = [
          Expanded(
            child: ElevatedButton(
              onPressed: () => onStatusUpdate(OrderStatus.preparing),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Start Preparing'),
            ),
          ),
        ];
        break;
      case OrderStatus.preparing:
        buttons = [
          Expanded(
            child: ElevatedButton(
              onPressed: () => onStatusUpdate(OrderStatus.ready),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Mark as Ready'),
            ),
          ),
        ];
        break;
      // case OrderStatus.ready:
      //   buttons = [
      //     Expanded(
      //       child: ElevatedButton(
      //         onPressed: () => onStatusUpdate(OrderStatus.shipped),
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: Colors.purple,
      //           foregroundColor: Colors.white,
      //         ),
      //         child: const Text('Mark as Shipped'),
      //       ),
      //     ),
      //   ];
      //   break;
      // case OrderStatus.shipped:
      //   buttons = [
      //     Expanded(
      //       child: ElevatedButton(
      //         onPressed: () => onStatusUpdate(OrderStatus.delivered),
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: Colors.green,
      //           foregroundColor: Colors.white,
      //         ),
      //         child: const Text('Mark as Delivered'),
      //       ),
      //     ),
      //   ];
      //   break;
      default:
        buttons = [
          Text(
            'Order ${status.name.toUpperCase()}',
            style: TextStyle(
              color: _getStatusColor(status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ];
    }

    return Row(mainAxisAlignment: MainAxisAlignment.end, children: buttons);
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.accepted:
        return Colors.green;
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.ready:
        return Colors.purple;
      case OrderStatus.shipped:
        return Colors.green;
      case OrderStatus.delivered:
        return Colors.teal;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
