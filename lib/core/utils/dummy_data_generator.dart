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
    return 20 + _random.nextInt(81); // Random stock between 20 and 100
  }

  static String _getRandomImage(ProductCategory category) {
    final imageUrls = {
      ProductCategory.vegetables: [
        'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37',
        'https://images.unsplash.com/photo-1594282486552-05b4d80fbb9f',
        'https://images.unsplash.com/photo-1546094094091-8c6b44943661',
      ],
      ProductCategory.seafoods: [
        'https://images.unsplash.com/photo-1544943910-4c1dc44aab44',
        'https://images.unsplash.com/photo-1565680018434-b583b12be0d3',
        'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2',
      ],
      ProductCategory.fruits: [
        'https://images.unsplash.com/photo-1553279768-865429fa0078',
        'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e',
        'https://images.unsplash.com/photo-1568702846914-96b305d2aaeb',
      ],
      ProductCategory.rice: [
        'https://images.unsplash.com/photo-1586201375761-83865001e31c',
        'https://images.unsplash.com/photo-1595661677316-65c961c7b18e',
        'https://images.unsplash.com/photo-1586201375761-83865001e31c',
      ],
    };

    final categoryImages = imageUrls[category]!;
    return categoryImages[_random.nextInt(categoryImages.length)];
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
        category: productData['category'] as ProductCategory,
        sellerId: sellerId,
        createdAt: DateTime.now(),
      );

      batch.set(docRef, product.toJson());
    }

    await batch.commit();
  }
}
