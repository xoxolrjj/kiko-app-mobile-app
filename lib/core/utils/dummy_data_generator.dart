import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiko_app_mobile_app/core/models/product_model.dart';

class DummyDataGenerator {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final Random _random = Random();

  static final List<String> _vegetableNames = [
    'Carrots',
    'Cabbage',
    'Tomatoes',
    'Broccoli',
    'Spinach',
    'Bell Peppers',
    'Cucumber',
    'Eggplant',
    'Lettuce',
    'Potatoes',
  ];

  static final List<String> _seafoodNames = [
    'Tilapia',
    'Shrimp',
    'Salmon',
    'Tuna',
    'Crab',
    'Squid',
    'Milkfish',
    'Mackerel',
    'Cod',
    'Sea Bass',
  ];

  static final List<String> _fruitNames = [
    'Mangoes',
    'Bananas',
    'Apples',
    'Oranges',
    'Grapes',
    'Pineapple',
    'Watermelon',
    'Papaya',
    'Lemon',
    'Strawberries',
  ];

  static final List<String> _riceTypes = [
    'Jasmine Rice',
    'Brown Rice',
    'White Rice',
    'Black Rice',
    'Red Rice',
    'Basmati Rice',
    'Sticky Rice',
    'Long Grain Rice',
    'Short Grain Rice',
    'Wild Rice',
  ];

  static String _generateDescription(String name, ProductCategory category) {
    final qualities = [
      'Fresh',
      'Premium',
      'Organic',
      'High-quality',
      'Hand-picked',
    ];
    final benefits = {
      ProductCategory.vegetables: [
        'rich in vitamins',
        'locally grown',
        'perfect for salads',
        'great for cooking',
      ],
      ProductCategory.seafoods: [
        'fresh catch',
        'rich in omega-3',
        'perfect for grilling',
        'sustainably sourced',
      ],
      ProductCategory.fruits: [
        'naturally sweet',
        'perfectly ripe',
        'great for snacking',
        'rich in antioxidants',
      ],
      ProductCategory.rice: [
        'premium quality',
        'perfect for everyday meals',
        'rich in nutrients',
        'carefully selected',
      ],
    };

    final quality = qualities[_random.nextInt(qualities.length)];
    final benefit =
        benefits[category]![_random.nextInt(benefits[category]!.length)];
    return '$quality $name, $benefit';
  }

  static double _generatePrice(ProductCategory category) {
    final priceRanges = {
      ProductCategory.vegetables: [500.0, 2000.0],
      ProductCategory.seafoods: [2000.0, 5000.0],
      ProductCategory.fruits: [800.0, 3000.0],
      ProductCategory.rice: [1500.0, 4000.0],
    };

    final range = priceRanges[category]!;
    return range[0] + _random.nextDouble() * (range[1] - range[0]);
  }

  static int _generateStock() {
    return 5; // All products start with 5 stock
  }

  static String _getRandomImage(ProductCategory category) {
    // Using picsum.photos for reliable placeholder images
    // Different image IDs for each category to provide variety
    final imageIds = {
      ProductCategory.vegetables: [200, 201, 202, 203, 204],
      ProductCategory.seafoods: [300, 301, 302, 303, 304],
      ProductCategory.fruits: [400, 401, 402, 403, 404],
      ProductCategory.rice: [500, 501, 502, 503, 504],
    };

    final categoryImages = imageIds[category]!;
    return 'https://picsum.photos/200/300?random=${categoryImages[_random.nextInt(categoryImages.length)]}';
  }

  static List<Map<String, dynamic>> _generateRandomProducts(int count) {
    final products = <Map<String, dynamic>>[];

    for (int i = 0; i < count; i++) {
      final category =
          ProductCategory.values[_random.nextInt(
            ProductCategory.values.length,
          )];
      final names =
          {
            ProductCategory.vegetables: _vegetableNames,
            ProductCategory.seafoods: _seafoodNames,
            ProductCategory.fruits: _fruitNames,
            ProductCategory.rice: _riceTypes,
          }[category]!;

      final name = names[_random.nextInt(names.length)];

      products.add({
        'name': name,
        'description': _generateDescription(name, category),
        'price': _generatePrice(category),
        'stock': _generateStock(),
        'category': category,
        'images': [_getRandomImage(category)],
      });
    }

    return products;
  }

  static Future<void> generateDummyProducts(
    String sellerId, {
    int count = 20,
  }) async {
    final batch = _firestore.batch();
    final products = _generateRandomProducts(count);

    for (final productData in products) {
      final docRef = _firestore.collection('products').doc();
      final product = ProductModel(
        id: docRef.id,
        name: productData['name'] as String,
        description: productData['description'] as String,
        pricePerSack: productData['price'] as double,
        stock: productData['stock'] as int,
        imagePath: (productData['images'] as List<String>).first,
        category:
            productData['category'] is ProductCategory
                ? productData['category'] as ProductCategory
                : ProductCategory.vegetables, // Fallback if cast fails
        sellerId: sellerId,
        createdAt: DateTime.now(),
      );

      batch.set(docRef, product.toJson());
    }

    await batch.commit();
  }
}
