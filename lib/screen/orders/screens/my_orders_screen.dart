import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kiko_app_mobile_app/core/models/order_model.dart';
import 'package:provider/provider.dart';
import 'package:kiko_app_mobile_app/core/stores/auth_store.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);

    final authStore = Provider.of<AuthStore>(context, listen: false);
    userId = authStore.currentUser?.id;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Orders'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/profile'),
          ),
        ),
        body: const Center(child: Text('Please log in to view your orders')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
            Tab(text: 'Preparing'),
            Tab(text: 'Ready'),
            Tab(text: 'Shipped'),
            Tab(text: 'Delivered'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(null), // All orders
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

  Widget _buildOrdersList(OrderStatus? status) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('orders')
        .where('buyerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
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
                  Icons.shopping_bag_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  status == null ? 'No orders yet' : 'No ${status.name} orders',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  status == null
                      ? 'Start shopping to see your orders here'
                      : _getEmptyMessage(status),
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
            final order = OrderModel.fromSnapshot(orders[index]);
            return _OrderCard(order: order);
          },
        );
      },
    );
  }

  String _getEmptyMessage(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'No pending orders';
      case OrderStatus.accepted:
        return 'No accepted orders';
      case OrderStatus.preparing:
        return 'No orders being prepared';
      case OrderStatus.ready:
        return 'No orders ready for pickup';
      case OrderStatus.shipped:
        return 'No shipped orders';
      case OrderStatus.delivered:
        return 'No delivered orders';
      case OrderStatus.cancelled:
        return 'No cancelled orders';
    }
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(order.status),
          child: Icon(_getStatusIcon(order.status), color: Colors.white),
        ),
        title: Text(
          'Order #${order.id.substring(0, 8)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Seller: ${order.sellerName}'),
            Text('Total: ₱${order.totalAmount.toStringAsFixed(2)}'),
            Text('Status: ${order.status.name.toUpperCase()}'),
            Text('Date: ${_formatDate(order.createdAt)}'),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Items
                _buildSectionTitle('Order Items'),
                const SizedBox(height: 8),
                ...order.items.map((item) => _buildOrderItem(item)).toList(),

                const SizedBox(height: 16),

                // Delivery Information
                _buildSectionTitle('Delivery Information'),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.location_on,
                  label: 'Address',
                  value: order.deliveryAddress,
                ),
                _InfoRow(
                  icon: Icons.phone,
                  label: 'Phone',
                  value: order.buyerPhone,
                ),

                if (order.notes?.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  _buildSectionTitle('Order Notes'),
                  const SizedBox(height: 8),
                  Text(order.notes!),
                ],

                const SizedBox(height: 16),

                // Order Timeline
                _buildOrderTimeline(),

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
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₱${order.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                if (_canCancelOrder()) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/cancel-order/${order.id}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Cancel Order',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
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
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              item.productImage,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Quantity: ${item.quantity} sacks'),
                Text('₱${item.pricePerUnit.toStringAsFixed(2)} per sack'),
              ],
            ),
          ),
          Text(
            '₱${item.totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Order Timeline'),
        const SizedBox(height: 8),
        _TimelineItem(
          icon: Icons.shopping_cart,
          title: 'Order Placed',
          date: order.createdAt,
          isCompleted: true,
        ),
        if (order.acceptedAt != null)
          _TimelineItem(
            icon: Icons.check_circle,
            title: 'Order Accepted',
            date: order.acceptedAt!,
            isCompleted: true,
          ),
        if (order.readyAt != null)
          _TimelineItem(
            icon: Icons.kitchen,
            title: 'Order Ready',
            date: order.readyAt!,
            isCompleted: true,
          ),
        if (order.shippedAt != null)
          _TimelineItem(
            icon: Icons.local_shipping,
            title: 'Order Shipped',
            date: order.shippedAt!,
            isCompleted: true,
          ),
        if (order.deliveredAt != null)
          _TimelineItem(
            icon: Icons.done_all,
            title: 'Order Delivered',
            date: order.deliveredAt!,
            isCompleted: true,
          ),
      ],
    );
  }

  bool _canCancelOrder() {
    return order.status == OrderStatus.pending ||
        order.status == OrderStatus.accepted ||
        order.status == OrderStatus.preparing;
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.accepted:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.purple;
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.shipped:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.teal;
      case OrderStatus.cancelled:
        return Colors.red;
    }
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final DateTime date;
  final bool isCompleted;

  const _TimelineItem({
    required this.icon,
    required this.title,
    required this.date,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight:
                        isCompleted ? FontWeight.bold : FontWeight.normal,
                    color: isCompleted ? Colors.black : Colors.grey,
                  ),
                ),
                Text(
                  _formatDate(date),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
