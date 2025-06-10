import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kiko_app_mobile_app/core/models/product_model.dart';
import 'package:kiko_app_mobile_app/core/models/order_model.dart';
import 'package:kiko_app_mobile_app/core/stores/auth_store.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  final ProductModel product;
  final int quantity;
  final Map<String, dynamic> sellerData;

  const CheckoutScreen({
    super.key,
    required this.product,
    required this.quantity,
    required this.sellerData,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedPaymentMethod = 'Cash on Delivery';
  bool _isPlacingOrder = false;

  final double _deliveryFee = 100.0;
  final double _platformFee = 20.0;

  double get _subtotal => widget.product.pricePerSack * widget.quantity;
  double get _total => _subtotal + _deliveryFee + _platformFee;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    final user = authStore.currentUser;
    if (user != null) {
      _phoneController.text = user.phoneNumber ?? '';
      _addressController.text = user.location ?? '';
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final authStore = context.read<AuthStore>();
      if (authStore.currentUser == null) {
        throw Exception('User data not found');
      }

      // Create order
      final orderRef = FirebaseFirestore.instance.collection('orders').doc();
      final orderData = {
        'id': orderRef.id,
        'buyerId': user.uid,
        'buyerName': authStore.currentUser!.name,
        'sellerId': widget.product.sellerId,
        'sellerName':
            widget.sellerData['businessName'] ??
            widget.sellerData['name'] ??
            'Unknown Seller',
        'productId': widget.product.id,
        'productName': widget.product.name,
        'quantity': widget.quantity,
        'totalAmount': widget.quantity * widget.product.pricePerSack,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await orderRef.set(orderData);

      // Check for existing conversation with this seller
      final existingConversationQuery =
          await FirebaseFirestore.instance
              .collection('conversations')
              .where('buyerId', isEqualTo: user.uid)
              .where('sellerId', isEqualTo: widget.product.sellerId)
              .limit(1)
              .get();

      String conversationId;
      if (existingConversationQuery.docs.isNotEmpty) {
        // Use existing conversation
        conversationId = existingConversationQuery.docs.first.id;

        // Update conversation with new order info
        await FirebaseFirestore.instance
            .collection('conversations')
            .doc(conversationId)
            .update({'updatedAt': FieldValue.serverTimestamp()});
      } else {
        // Create new conversation
        final conversationRef =
            FirebaseFirestore.instance.collection('conversations').doc();
        conversationId = conversationRef.id;
        final conversationData = {
          'id': conversationId,
          'buyerId': user.uid,
          'buyerName': authStore.currentUser!.name,
          'sellerId': widget.product.sellerId,
          'sellerName':
              widget.sellerData['businessName'] ??
              widget.sellerData['name'] ??
              'Unknown Seller',
          'orderId': orderRef.id,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        await conversationRef.set(conversationData);
      }

      // Add message about the new order
      final messageRef =
          FirebaseFirestore.instance.collection('messages').doc();
      final messageData = {
        'id': messageRef.id,
        'conversationId': conversationId,
        'senderId': user.uid,
        'senderName': authStore.currentUser!.name,
        'content':
            'Order #${orderRef.id} has been placed. ${widget.quantity} sacks of ${widget.product.name}',
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      };
      await messageRef.set(messageData);

      // Update conversation with last message
      await FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationId)
          .update({
            'lastMessage': messageData['content'],
            'lastMessageTime': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to my orders screen
        context.go('/my-orders');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error placing order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/product-details/${widget.product.id}'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary
              _buildOrderSummarySection(),

              const SizedBox(height: 24),

              // Delivery Address
              _buildDeliveryAddressSection(),

              const SizedBox(height: 24),

              // Order Notes
              _buildOrderNotesSection(),

              const SizedBox(height: 24),

              // Price Breakdown
              _buildPriceBreakdownSection(),

              const SizedBox(height: 32),

              // Place Order Button
              _buildPlaceOrderButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummarySection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.product.imagePath,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                  ),
                ),
                const SizedBox(width: 16),

                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Category: ${widget.product.category.name.toUpperCase()}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quantity: ${widget.quantity} sacks',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₱${widget.product.pricePerSack.toStringAsFixed(2)} per sack',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Seller Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.store, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seller: ${widget.sellerData['businessName'] ?? widget.sellerData['name'] ?? 'Unknown'}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (widget.sellerData['shopLocation'] != null)
                          Text(
                            widget.sellerData['shopLocation'],
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryAddressSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Address',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Phone number is required';
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Delivery Address',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value?.isEmpty ?? true)
                  return 'Delivery address is required';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderNotesSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Notes (Optional)',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Any special instructions or notes',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdownSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Breakdown',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildPriceRow('Subtotal (${widget.quantity} sacks)', _subtotal),
            _buildPriceRow('Delivery Fee', _deliveryFee),
            _buildPriceRow('Platform Fee', _platformFee),

            const Divider(thickness: 2),

            _buildPriceRow('Total', _total, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : null,
            ),
          ),
          Text(
            '₱${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : null,
              color: isTotal ? Theme.of(context).primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceOrderButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isPlacingOrder ? null : _placeOrder,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        child:
            _isPlacingOrder
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  'Place Order - ₱${_total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }
}
