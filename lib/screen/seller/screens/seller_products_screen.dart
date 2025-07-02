import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kiko_app_mobile_app/core/models/product_model.dart';
import 'package:kiko_app_mobile_app/core/stores/product_store.dart';
import 'package:kiko_app_mobile_app/core/stores/auth_store.dart';

class SellerProductsScreen extends StatefulWidget {
  const SellerProductsScreen({super.key});

  @override
  State<SellerProductsScreen> createState() => _SellerProductsScreenState();
}

class _SellerProductsScreenState extends State<SellerProductsScreen> {
  late ProductStore _productStore;
  String? sellerId;

  @override
  void initState() {
    super.initState();
    _productStore = Provider.of<ProductStore>(context, listen: false);
    _loadSellerProducts();
  }

  void _loadSellerProducts() {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    sellerId = authStore.currentUser?.id;
    if (sellerId != null) {
      _loadProductsBySeller();
    }
  }

  Future<void> _loadProductsBySeller() async {
    // Load only products for this seller
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('products')
              .where('sellerId', isEqualTo: sellerId)
              .get();

      final sellerProducts =
          snapshot.docs
              .map((doc) => ProductModel.fromSnapshot(doc))
              .where(
                (product) => product.id.isNotEmpty && product.name.isNotEmpty,
              )
              .toList();

      _productStore.products.clear();
      _productStore.products.addAll(sellerProducts);
    } catch (e) {
      debugPrint('Error loading seller products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/profile'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('My Products'),
        actions: [
          if (_productStore.products.isNotEmpty)
            IconButton(
              onPressed: () => _showCreateProductDialog(),
              icon: const Icon(Icons.add),
              tooltip: 'Add Product',
            ),
        ],
      ),
      body: Observer(
        builder: (_) {
          if (_productStore.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_productStore.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(
                    _productStore.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProductsBySeller,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final products = _productStore.products;

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first product to start selling',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showCreateProductDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadProductsBySeller,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _ProductCard(
                  product: product,
                  onEdit: () => _showEditProductDialog(product),
                  onDelete: () => _showDeleteConfirmation(product),
                  onTap: () => _showProductDetails(product),
                );
              },
            ),
          );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _showCreateProductDialog,
      //   backgroundColor: Colors.green,
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
    );
  }

  void _showCreateProductDialog() {
    context.go('/create-product');
  }

  void _showEditProductDialog(ProductModel product) {
    context.go('/edit-product', extra: product);
  }

  void _showProductDetails(ProductModel product) {
    context.go('/product-details', extra: product);
  }

  void _showDeleteConfirmation(ProductModel product) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Product'),
            content: Text('Are you sure you want to delete "${product.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _deleteProduct(product);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteProduct(ProductModel product) async {
    try {
      await _productStore.deleteProduct(product.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
      await _loadProductsBySeller();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child:
                      product.imagePath.isNotEmpty
                          ? CachedNetworkImage(
                            imageUrl: product.imagePath,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
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
              const SizedBox(width: 16),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₱${product.pricePerSack.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.inventory,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.stock > 0
                              ? 'Stock: ${product.stock}'
                              : 'Out of Stock',
                          style: TextStyle(
                            color:
                                product.stock > 0
                                    ? Colors.grey.shade600
                                    : Colors.red,
                            fontSize: 14,
                            fontWeight:
                                product.stock > 0
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.category.name.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Column(
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit),
                    color: Colors.blue,
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
