import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiko_app_mobile_app/core/models/product_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  ProductCategory? _selectedCategory;

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
        title: const Text('Product Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Products', icon: Icon(Icons.inventory)),
            Tab(text: 'By Category', icon: Icon(Icons.category)),
            Tab(text: 'By Seller', icon: Icon(Icons.store)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllProductsTab(),
          _buildByCategoryTab(),
          _buildBySellerTab(),
        ],
      ),
    );
  }

  Widget _buildAllProductsTab() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search products...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        // Products List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('products')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final products = snapshot.data?.docs ?? [];
              final filteredProducts =
                  products.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final productName =
                        (data['name'] as String? ?? '').toLowerCase();
                    return _searchQuery.isEmpty ||
                        productName.contains(_searchQuery);
                  }).toList();

              if (filteredProducts.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No products found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final productData =
                      filteredProducts[index].data() as Map<String, dynamic>;
                  final product = ProductModel.fromSnapshot(
                    filteredProducts[index],
                  );
                  return _ProductCard(
                    product: product,
                    productId: filteredProducts[index].id,
                    //    onDelete: () => _deleteProduct(filteredProducts[index].id),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildByCategoryTab() {
    return Column(
      children: [
        // Category Filter
        Padding(
          padding: const EdgeInsets.all(16),
          child: DropdownButtonFormField<ProductCategory>(
            decoration: const InputDecoration(
              labelText: 'Filter by Category',
              border: OutlineInputBorder(),
            ),
            value: _selectedCategory,
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Categories'),
              ),
              ...ProductCategory.values.map(
                (category) => DropdownMenuItem(
                  value: category,
                  child: Text(category.name.toUpperCase()),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
          ),
        ),
        // Products by Category
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                _selectedCategory != null
                    ? FirebaseFirestore.instance
                        .collection('products')
                        .where('category', isEqualTo: _selectedCategory!.name)
                        .orderBy('createdAt', descending: true)
                        .snapshots()
                    : FirebaseFirestore.instance
                        .collection('products')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final products = snapshot.data?.docs ?? [];

              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _selectedCategory != null
                            ? 'No products in ${_selectedCategory!.name} category'
                            : 'No products found',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = ProductModel.fromSnapshot(products[index]);
                  return _ProductCard(
                    product: product,
                    productId: products[index].id,
                    // onDelete: () => _deleteProduct(products[index].id),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBySellerTab() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('products')
              .orderBy('sellerId')
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data?.docs ?? [];

        // Group products by seller
        final Map<String, List<QueryDocumentSnapshot>> productsBySeller = {};
        for (final doc in products) {
          final data = doc.data() as Map<String, dynamic>;
          final sellerId = data['sellerId'] as String? ?? '';
          if (!productsBySeller.containsKey(sellerId)) {
            productsBySeller[sellerId] = [];
          }
          productsBySeller[sellerId]!.add(doc);
        }

        if (productsBySeller.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.store_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No sellers with products found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: productsBySeller.keys.length,
          itemBuilder: (context, index) {
            final sellerId = productsBySeller.keys.elementAt(index);
            final sellerProducts = productsBySeller[sellerId]!;
            return _SellerProductsCard(
              sellerId: sellerId,
              products: sellerProducts,
              //  onDeleteProduct: _deleteProduct,
            );
          },
        );
      },
    );
  }

  // Future<void> _deleteProduct(String productId) async {
  //   final confirmed = await showDialog<bool>(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           title: const Text('Delete Product'),
  //           content: const Text(
  //             'Are you sure you want to delete this product? This action cannot be undone.',
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.of(context).pop(false),
  //               child: const Text('Cancel'),
  //             ),
  //             TextButton(
  //               onPressed: () => Navigator.of(context).pop(true),
  //               style: TextButton.styleFrom(foregroundColor: Colors.red),
  //               child: const Text('Delete'),
  //             ),
  //           ],
  //         ),
  //   );

  //   if (confirmed == true) {
  //     try {
  //       await FirebaseFirestore.instance
  //           .collection('products')
  //           .doc(productId)
  //           .delete();

  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('Product deleted successfully'),
  //             backgroundColor: Colors.green,
  //           ),
  //         );
  //       }
  //     } catch (e) {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('Error deleting product: $e'),
  //             backgroundColor: Colors.red,
  //           ),
  //         );
  //       }
  //     }
  //   }
  // }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final String productId;
  //final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.productId,
    //   required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: product.imagePath,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Category: ${product.category.name.toUpperCase()}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₱${product.pricePerSack.toStringAsFixed(2)} per sack',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Posted: ${_formatDate(product.createdAt)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                TextButton.icon(
                  onPressed:
                      () => context.go('/product-details', extra: product), 
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View'),
                ),
                // Row(
                //   children: [
                //     TextButton.icon(
                //       onPressed:
                //           () => context.go('/product-details', extra: product),
                //       icon: const Icon(Icons.visibility, size: 16),
                //       label: const Text('View'),
                //     ),
                //     // TextButton.icon(
                //     // //  onPressed: onDelete,
                //     //   icon: const Icon(Icons.delete, size: 16),
                //     //   label: const Text('Delete'),
                //     //   style: TextButton.styleFrom(foregroundColor: Colors.red),
                //     // ),
                //   ],
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _SellerProductsCard extends StatefulWidget {
  final String sellerId;
  final List<QueryDocumentSnapshot> products;
  // final Function(String) onDeleteProduct;

  const _SellerProductsCard({
    required this.sellerId,
    required this.products,
    // required this.onDeleteProduct,
  });

  @override
  State<_SellerProductsCard> createState() => _SellerProductsCardState();
}

class _SellerProductsCardState extends State<_SellerProductsCard> {
  String? sellerName;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadSellerName();
  }

  Future<void> _loadSellerName() async {
    try {
      // Try sellers collection first
      // final sellerDoc =
      //     await FirebaseFirestore.instance
      //         .collection('sellers')
      //         .doc(widget.sellerId)
      //         .get();

      // if (sellerDoc.exists) {
      //   final data = sellerDoc.data() as Map<String, dynamic>;
      //   setState(() {
      //     sellerName = data['businessName'] ?? data['name'] ?? 'Unknown Seller';
      //   });
      //   return;
      // }

      // Try users collection
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.sellerId)
              .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          sellerName = data['name'] ?? 'Unknown Seller';
        });
      }
    } catch (e) {
      setState(() {
        sellerName = 'Unknown Seller';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: const Icon(Icons.store),
        title: Text(sellerName ?? 'Loading...'),
        subtitle: Text('${widget.products.length} products'),
        children:
            widget.products.map((doc) {
              final product = ProductModel.fromSnapshot(doc);
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: product.imagePath,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Container(
                          width: 40,
                          height: 40,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, size: 20),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          width: 40,
                          height: 40,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 20,
                          ),
                        ),
                  ),
                ),
                title: Text(product.name),
                subtitle: Text(
                  '₱${product.pricePerSack.toStringAsFixed(2)} per sack',
                ),
                trailing: IconButton(
                  onPressed:
                      () => context.go('/product-details', extra: product),
                  icon: const Icon(Icons.visibility),
                ),
                //  Row(
                //   mainAxisSize: MainAxisSize.min,
                //   children: [
                //     IconButton(
                //       onPressed:
                //           () => context.go('/product-details', extra: product),
                //       icon: const Icon(Icons.visibility),
                //     ),
                //     // IconButton(
                //     //   onPressed: () => widget.onDeleteProduct(doc.id),
                //     //   icon: const Icon(Icons.delete),
                //     //   color: Colors.red,
                //     // ),
                //   ],
                // ),
              );
            }).toList(),
      ),
    );
  }
}
