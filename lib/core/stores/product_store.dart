import 'dart:io';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kiko_app_mobile_app/dependency/dependency_manager.dart';
import 'package:mobx/mobx.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiko_app_mobile_app/core/models/product_model.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

part 'product_store.g.dart';

class ProductStore = _ProductStore with _$ProductStore;

abstract class _ProductStore with Store {
  final FirebaseFirestore _firestore;
  FirebaseStorage _storage = sl<FirebaseStorage>();
  final FirebaseAuth _auth = sl<FirebaseAuth>();

  _ProductStore()
    : _firestore = FirebaseFirestore.instance,
      _storage = FirebaseStorage.instance;

  @observable
  ObservableList<ProductModel> products = ObservableList<ProductModel>();

  @observable
  ProductCategory? selectedCategory;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @computed
  List<ProductModel> get filteredProducts {
    if (selectedCategory == null) return products;
    return products.where((p) => p.category == selectedCategory).toList();
  }

  @action
  void setSelectedCategory(ProductCategory? category) {
    selectedCategory = category;
  }

  @action
  Future<void> loadProducts() async {
    isLoading = true;
    try {
      final snapshot = await _firestore.collection('products').get();
      products = ObservableList.of(
        snapshot.docs
            .map((doc) => ProductModel.fromSnapshot(doc))
            .where(
              (product) => product.id.isNotEmpty && product.name.isNotEmpty,
            )
            .toList(),
      );
    } catch (e) {
      debugPrint('Error loading products: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> searchProducts(String query) async {
    try {
      isLoading = true;
      errorMessage = null;

      final snapshot = await _firestore.collection('products').get();

      products = ObservableList.of(
        snapshot.docs
            .map((doc) => ProductModel.fromSnapshot(doc))
            .where(
              (product) =>
                  product.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList(),
      );
    } catch (e) {
      errorMessage = 'Failed to search products: $e';
    } finally {
      isLoading = false;
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to upload files');
      }

      // Read file as bytes
      final bytes = await imageFile.readAsBytes();

      // Create a unique filename
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Create storage reference
      final storageRef = _storage.ref().child('images/$fileName');

      debugPrint('Starting upload to: images/$fileName');

      // Upload bytes directly
      await storageRef.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Get download URL
      String downloadURL = await storageRef.getDownloadURL();
      debugPrint('Upload successful. URL: $downloadURL');

      return downloadURL;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      if (e is FirebaseException) {
        debugPrint('Firebase error code: ${e.code}');
        debugPrint('Firebase error message: ${e.message}');
      }
      rethrow;
    }
  }

  // Future<String?> _uploadImage() async {
  //   if (_imageFile == null) return _profileImageUrl;

  //   try {
  //     final user = _auth.currentUser;
  //     if (user == null) return null;

  //     // Create a reference to the file location in Firebase Storage
  //     final storageRef = _storage.ref().child('profile_images/${user.uid}');

  //     // Upload the file
  //     final uploadTask = await storageRef.putFile(_imageFile!);

  //     // Get the download URL
  //     final downloadUrl = await uploadTask.ref.getDownloadURL();
  //     return downloadUrl;
  //   } catch (e) {
  //     print('Error uploading image: $e');
  //     return null;
  //   }
  // }
  @action
  Future<void> createProduct({
    required String name,
    required String description,
    required double pricePerSack,
    required int stock,
    required ProductCategory category,
    required String imagePath,
    required String sellerId,
  }) async {
    try {
      // Check authentication
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to create products');
      }
      debugPrint('User authenticated: ${user.uid}');

      // Upload image to Firebase Storage
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist at path: $imagePath');
      }
      debugPrint('Image file exists at path: $imagePath');

      debugPrint('Starting image upload for file: ${imageFile.path}');
      final downloadUrl = await _uploadImage(imageFile);
      debugPrint('Image upload completed. URL: $downloadUrl');

      // Create product document
      final docRef = await _firestore.collection('products').add({
        'name': name,
        'description': description,
        'pricePerSack': pricePerSack,
        'stock': stock,
        'category': category.name,
        'imagePath': downloadUrl,
        'sellerId': sellerId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Add the new product to the list
      final newProduct = ProductModel(
        id: docRef.id,
        name: name,
        description: description,
        pricePerSack: pricePerSack,
        stock: stock,
        category: category,
        imagePath: downloadUrl,
        sellerId: sellerId,
        createdAt: DateTime.now(),
      );

      products.add(newProduct);
    } catch (e) {
      debugPrint('Error creating product: $e');
      if (e is FirebaseException) {
        debugPrint('Firebase error code: ${e.code}');
        debugPrint('Firebase error message: ${e.message}');
      }
      rethrow;
    }
  }

  @action
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _firestore.collection('products').doc(product.id).update({
        'name': product.name,
        'description': product.description,
        'pricePerSack': product.pricePerSack,
        'stock': product.stock,
        'category': product.category.name,
        'imagePath': product.imagePath,
      });

      final index = products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        products[index] = product;
      }
    } catch (e) {
      debugPrint('Error updating product: $e');
      rethrow;
    }
  }

  @action
  Future<void> deleteProduct(String productId) async {
    try {
      // Get the product to find its image URL
      final product = products.firstWhere((p) => p.id == productId);

      // Delete the image from Firebase Storage if it exists
      if (product.imagePath.isNotEmpty) {
        try {
          final ref = _storage.refFromURL(product.imagePath);
          await ref.delete();
        } catch (e) {
          debugPrint('Error deleting image: $e');
        }
      }

      // Delete the product document
      await _firestore.collection('products').doc(productId).delete();
      products.removeWhere((product) => product.id == productId);
    } catch (e) {
      debugPrint('Error deleting product: $e');
      rethrow;
    }
  }
}
