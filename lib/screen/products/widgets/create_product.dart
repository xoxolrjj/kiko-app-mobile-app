import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kiko_app_mobile_app/core/models/product_model.dart';
import 'package:kiko_app_mobile_app/core/stores/product_store.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:kiko_app_mobile_app/core/stores/auth_store.dart';

class CreateProduct extends StatefulWidget {
  final ProductModel? productToEdit;

  const CreateProduct({super.key, this.productToEdit});

  @override
  State<CreateProduct> createState() => _CreateProductState();
}

class _CreateProductState extends State<CreateProduct> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pricePerSackController = TextEditingController();
  final _stockController = TextEditingController();
  ProductCategory _selectedCategory = ProductCategory.vegetables;
  String? _selectedImage;
  String? _existingImageUrl;
  final _imagePicker = ImagePicker();
  bool _isLoading = false;

  bool get isEditing => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _populateFormWithExistingData();
    } else {
      // Set default stock to 5 for new products
      _stockController.text = '5';
    }
  }

  void _populateFormWithExistingData() {
    final product = widget.productToEdit!;
    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _pricePerSackController.text = product.pricePerSack.toString();
    _stockController.text = product.stock.toString();
    _selectedCategory = product.category;
    _existingImageUrl = product.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _pricePerSackController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image.path;
        _existingImageUrl =
            null; // Clear existing image when new one is selected
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authStore = Provider.of<AuthStore>(context, listen: false);
      final user = authStore.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      // Check if seller is restricted
      if (user.isRestricted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Your account has been restricted from uploading products. Please contact support.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final productStore = Provider.of<ProductStore>(context, listen: false);

      if (isEditing && widget.productToEdit != null) {
        // Update existing product
        final updatedProduct = widget.productToEdit!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          pricePerSack: double.parse(_pricePerSackController.text.trim()),
          stock: int.parse(_stockController.text.trim()),
          category: _selectedCategory,
          imagePath: _selectedImage ?? widget.productToEdit!.imagePath,
        );

        await productStore.updateProduct(updatedProduct);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully')),
          );
          context.go('/seller/products');
        }
      } else {
        // Create new product
        await productStore.createProduct(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          pricePerSack: double.parse(_pricePerSackController.text.trim()),
          stock: int.parse(_stockController.text.trim()),
          category: _selectedCategory,
          imagePath: _selectedImage!,
          sellerId: user.id,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product created successfully')),
          );
          context.go('/seller/products');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error ${isEditing ? "updating" : "creating"} product: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.go('/seller/products');
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(isEditing ? 'Edit Product' : 'Create Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator:
                    (value) =>
                        value?.isEmpty ?? true ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ProductCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items:
                    ProductCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category.name.toUpperCase()),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pricePerSackController,
                decoration: const InputDecoration(
                  labelText: 'Price per Sack',
                  prefixText: '₱',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true)
                    return 'Please enter a price per sack';
                  if (double.tryParse(value!) == null) return 'Invalid price';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Stock',
                  hintText: 'Default: 5 sacks',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter stock';
                  if (int.tryParse(value!) == null) return 'Invalid stock';
                  final stock = int.parse(value!);
                  if (stock < 0) return 'Stock cannot be negative';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator:
                    (value) =>
                        value?.isEmpty ?? true
                            ? 'Please enter a description'
                            : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Product Image',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_photo_alternate),
                    onPressed: _pickImage,
                  ),
                ],
              ),
              if (_selectedImage != null)
                Stack(
                  children: [
                    Image.file(
                      File(_selectedImage!),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed:
                            () => setState(() {
                              _selectedImage = null;
                            }),
                      ),
                    ),
                  ],
                )
              else if (_existingImageUrl != null)
                Stack(
                  children: [
                    Image.network(
                      _existingImageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed:
                            () => setState(() {
                              _existingImageUrl = null;
                            }),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () {
                                context.go('/seller/products');
                              },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(isEditing ? 'Update' : 'Create'),
                    ),
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
