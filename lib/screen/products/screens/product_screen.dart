import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kiko_app_mobile_app/core/models/product_model.dart';
import 'package:kiko_app_mobile_app/core/utils/dummy_data_generator.dart';
import 'package:kiko_app_mobile_app/screen/products/screens/product_details_screen.dart';
import 'package:kiko_app_mobile_app/core/stores/product_store.dart';
import 'package:kiko_app_mobile_app/screen/products/widgets/create_product.dart';
import 'package:kiko_app_mobile_app/screen/widgets/kiko_images.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class ProductScreen extends StatefulWidget {
  final ProductCategory? category;

  const ProductScreen({super.key, this.category});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late final ProductStore _productStore;

  @override
  void initState() {
    super.initState();
    _productStore = ProductStore();
    _loadProducts();
    _handleInitialCategory();
  }

  void _handleInitialCategory() {
    if (widget.category != null) {
      _productStore.setSelectedCategory(widget.category);
    }
  }

  Future<void> _loadProducts() async {
    await _productStore.loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<ProductStore>.value(
      value: _productStore,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Products',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
          actions: [
            ElevatedButton.icon(
              onPressed: () => _generateDummyData(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Dummy Data'),
            ),
            //   ElevatedButton.icon(
            //     onPressed: () {
            //       context.push('/create-product');
            //     },
            //     icon: const Icon(Icons.add),
            //     label: const Text('Create Product'),
            //   ),
          ],
          elevation: 1,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show search and category filter only when not coming from home category selection
                if (widget.category == null) ...[
                  TextField(
                    onChanged: _productStore.searchProducts,
                    decoration: InputDecoration(
                      labelText: 'Search Products',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildCategoryFilter(context),
                  const SizedBox(height: 16),
                ],
                // Show category title when coming from home category selection
                if (widget.category != null) ...[
                  Text(
                    '${widget.category!.name.toUpperCase()} PRODUCTS',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Expanded(child: _buildProductGrid(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return Observer(
      builder:
          (_) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  ProductCategory.values.map((category) {
                    final isSelected =
                        _productStore.selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(category.name.toUpperCase()),
                        onSelected: (selected) {
                          _productStore.setSelectedCategory(
                            selected ? category : null,
                          );
                        },
                        selected: isSelected,
                      ),
                    );
                  }).toList(),
            ),
          ),
    );
  }

  Widget _buildProductGrid(BuildContext context) {
    return Observer(
      builder: (_) {
        if (_productStore.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_productStore.errorMessage != null) {
          return Center(
            child: Text(
              _productStore.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final products = _productStore.filteredProducts;
        if (products.isEmpty) {
          return const Center(child: Text('No products found'));
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(product: product);
          },
          itemCount: products.length,
        );
      },
    );
  }

  // void _showCreateProductDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => const CreateProductDialog(),
  //   );
  // }

  Future<void> _generateDummyData(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please login first')));
        return;
      }

      await DummyDataGenerator.generateDummyProducts(user.uid);
      await _loadProducts(); // Reload products after generating dummy data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dummy products generated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating dummy data: $e')),
      );
    }
  }
}

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  String _formatPrice(double price) {
    return '₱${price.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/product-details', extra: product);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: Colors.grey[200],
                child: KikoImage(imagePath: product.imagePath),
                // product.imagePath.isNotEmpty
                //     ? Image.file(
                //       File(product.imagePath),
                //       fit: BoxFit.cover,
                //       errorBuilder:
                //           (context, error, stackTrace) => const Icon(
                //             Icons.image,
                //             size: 50,
                //             color: Colors.grey,
                //           ),
                //     )
                //     : const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatPrice(product.pricePerSack),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category.name.toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
