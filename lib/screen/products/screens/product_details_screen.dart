import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiko_app_mobile_app/core/models/product_model.dart';
import 'package:kiko_app_mobile_app/core/stores/auth_store.dart';
import 'package:kiko_app_mobile_app/screen/widgets/kiko_images.dart';
import 'package:provider/provider.dart';
import 'package:kiko_app_mobile_app/core/models/user_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 5; // Default to 5 sacks
  Map<String, dynamic>? _sellerData;
  bool _isLoadingSeller = false;

  String _formatPrice(double price) {
    return '₱${price.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  void initState() {
    super.initState();
    _loadSellerData();
  }

  Future<void> _loadSellerData() async {
    setState(() {
      _isLoadingSeller = true;
    });

    try {
      // Load both seller and user data to combine information
      final sellerDoc =
          FirebaseFirestore.instance
              .collection('sellers')
              .doc(widget.product.sellerId)
              .get();

      final userDoc =
          FirebaseFirestore.instance
              .collection('users')
              .doc(widget.product.sellerId)
              .get();

      // Wait for both documents
      final results = await Future.wait([sellerDoc, userDoc]);
      final sellerSnapshot = results[0];
      final userSnapshot = results[1];

      Map<String, dynamic> combinedData = {};

      // Start with user data (contains name)
      if (userSnapshot.exists) {
        combinedData.addAll(userSnapshot.data() as Map<String, dynamic>);
      }

      // Override with seller-specific data (contains shop info)
      if (sellerSnapshot.exists) {
        combinedData.addAll(sellerSnapshot.data() as Map<String, dynamic>);
      }

      if (combinedData.isNotEmpty) {
        setState(() {
          _sellerData = combinedData;
          _isLoadingSeller = false;
        });
      } else {
        setState(() {
          _isLoadingSeller = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingSeller = false;
      });
      debugPrint('Error loading seller data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authStore = Provider.of<AuthStore>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            // Navigate back based on user role
            if (authStore.currentUser?.role == UserRole.seller) {
              context.go('/seller/products');
            } else if (authStore.currentUser?.role == UserRole.user) {
              context.go('/products');
            } else {
              context.go('/admin');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(widget.product.name),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.shopping_cart_outlined),
        //     onPressed: () {
        //       // TODO: Implement add to cart functionality
        //     },
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            if (widget.product.imagePath.isNotEmpty)
              Image.network(
                widget.product.imagePath,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                      ),
                    ),
                  );
                },
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      height: 300,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Category
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.product.category.name.toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Price per Sack
                  Text(
                    'Price per Sack',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    _formatPrice(widget.product.pricePerSack),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Seller Information
                  _buildSellerInfoSection(),

                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  // Quantity Selection
                  Text(
                    'Select Number of Sacks',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed:
                            _quantity > 5
                                ? () => setState(() => _quantity -= 1)
                                : null,
                      ),
                      Text(
                        '$_quantity sacks',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() => _quantity += 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Price: ₱${(widget.product.pricePerSack * _quantity).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Buy Now Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final authStore = Provider.of<AuthStore>(
                          context,
                          listen: false,
                        );
                        if (authStore.currentUser?.role == UserRole.seller) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sellers cannot purchase products'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        if (authStore.currentUser?.role == UserRole.user) {
                          context.go(
                            '/checkout',
                            extra: {
                              'product': widget.product,
                              'quantity': _quantity,
                              'sellerData': _sellerData!,
                            },
                          );
                        }
                        // if (_sellerData != null) {
                        //   context.go(
                        //     '/checkout',
                        //     extra: {
                        //       'product': widget.product,
                        //       'quantity': _quantity,
                        //       'sellerData': _sellerData!,
                        //     },
                        //   );
                        // }
                        else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Admin cannot purchase products'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        Provider.of<AuthStore>(context).currentUser?.role ==
                                UserRole.seller
                            ? 'Sellers Cannot Purchase'
                            : Provider.of<AuthStore>(
                                  context,
                                ).currentUser?.role ==
                                UserRole.user
                            ? 'Buy Now'
                            : 'Admin Cannot Purchase',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildSellerInfoSection() {
    if (_isLoadingSeller) {
      return Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Loading seller information...'),
            ],
          ),
        ),
      );
    }

    if (_sellerData == null) {
      return Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.grey),
              SizedBox(width: 16),
              Text('Seller information unavailable'),
            ],
          ),
        ),
      );
    }

    final sellerName = _sellerData!['name'] ?? 'Unknown Seller';
    final shopName = _sellerData!['shopName'] ?? 'Shop Name Not Available';
    final shopLocation =
        _sellerData!['shopLocation'] ?? 'Location Not Available';
    final contactNumber =
        _sellerData!['contactNumber'] ?? 'Contact Not Available';
    final profilePhotoUrl = _sellerData!['profilePhotoUrl'] ?? '';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seller Details
            Row(
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      profilePhotoUrl.isNotEmpty
                          ? NetworkImage(profilePhotoUrl)
                          : null,
                  child:
                      profilePhotoUrl.isEmpty
                          ? Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.grey.shade600,
                          )
                          : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sellerName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        shopName,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        shopLocation,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.phone),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        contactNumber,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
