import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiko_app_mobile_app/core/commons/utils.dart';

part 'product_model.freezed.dart';

enum ProductCategory { vegetables, seafoods, fruits, rice }

@freezed
class ProductModel with _$ProductModel {
  factory ProductModel({
    required String id,
    required String name,
    required String description,
    required double pricePerSack,
    required int stock,
    required String imagePath,
    required ProductCategory category,
    required String sellerId,
    required DateTime createdAt,
  }) = _ProductModel;
  ProductModel._();

  factory ProductModel.isEmpty() {
    return ProductModel(
      id: '',
      name: '',
      description: '',
      pricePerSack: 0.0,
      stock: 0,
      imagePath: '',
      category: ProductCategory.vegetables,
      sellerId: '',
      createdAt: DateTime.now(),
    );
  }

  factory ProductModel.fromSnapshot(DocumentSnapshot doc) {
    if (doc.data() == null) {
      return ProductModel.isEmpty();
    }

    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: cast<String>(data['name']) ?? '',
      description: cast<String>(data['description']) ?? '',
      pricePerSack: (cast<num>(data['pricePerSack']) ?? 0).toDouble(),
      stock: cast<int>(data['stock']) ?? 0,
      imagePath: cast<String>(data['imagePath']) ?? '',
      category: ProductCategory.values.firstWhere(
        (e) => e.toString() == 'ProductCategory.${data['category']}',
        orElse: () => ProductCategory.vegetables,
      ),
      sellerId: cast<String>(data['sellerId']) ?? '',
      createdAt: (cast<Timestamp>(data['createdAt']) ?? Timestamp.now()).toDate(),
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: cast<String>(json['id']) ?? '',
      name: cast<String>(json['name']) ?? '',
      description: cast<String>(json['description']) ?? '',
      pricePerSack: (cast<num>(json['pricePerSack']) ?? 0).toDouble(),
      stock: cast<int>(json['stock']) ?? 0,
      imagePath: cast<String>(json['imagePath']) ?? '',
      category: ProductCategory.values.firstWhere(
        (e) => e.toString() == 'ProductCategory.${json['category']}',
        orElse: () => ProductCategory.vegetables,
      ),
      sellerId: cast<String>(json['sellerId']) ?? '',
      createdAt: (cast<Timestamp>(json['createdAt']) ?? Timestamp.now()).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pricePerSack': pricePerSack,
      'stock': stock,
      'imagePath': imagePath,
      'category': category.name,
      'sellerId': sellerId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
