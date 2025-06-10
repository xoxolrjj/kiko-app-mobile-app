// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ProductStore on _ProductStore, Store {
  Computed<List<ProductModel>>? _$filteredProductsComputed;

  @override
  List<ProductModel> get filteredProducts =>
      (_$filteredProductsComputed ??= Computed<List<ProductModel>>(
            () => super.filteredProducts,
            name: '_ProductStore.filteredProducts',
          ))
          .value;

  late final _$productsAtom = Atom(
    name: '_ProductStore.products',
    context: context,
  );

  @override
  ObservableList<ProductModel> get products {
    _$productsAtom.reportRead();
    return super.products;
  }

  @override
  set products(ObservableList<ProductModel> value) {
    _$productsAtom.reportWrite(value, super.products, () {
      super.products = value;
    });
  }

  late final _$selectedCategoryAtom = Atom(
    name: '_ProductStore.selectedCategory',
    context: context,
  );

  @override
  ProductCategory? get selectedCategory {
    _$selectedCategoryAtom.reportRead();
    return super.selectedCategory;
  }

  @override
  set selectedCategory(ProductCategory? value) {
    _$selectedCategoryAtom.reportWrite(value, super.selectedCategory, () {
      super.selectedCategory = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: '_ProductStore.isLoading',
    context: context,
  );

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: '_ProductStore.errorMessage',
    context: context,
  );

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$loadProductsAsyncAction = AsyncAction(
    '_ProductStore.loadProducts',
    context: context,
  );

  @override
  Future<void> loadProducts() {
    return _$loadProductsAsyncAction.run(() => super.loadProducts());
  }

  late final _$searchProductsAsyncAction = AsyncAction(
    '_ProductStore.searchProducts',
    context: context,
  );

  @override
  Future<void> searchProducts(String query) {
    return _$searchProductsAsyncAction.run(() => super.searchProducts(query));
  }

  late final _$createProductAsyncAction = AsyncAction(
    '_ProductStore.createProduct',
    context: context,
  );

  @override
  Future<void> createProduct({
    required String name,
    required String description,
    required double pricePerSack,
    required int stock,
    required ProductCategory category,
    required String imagePath,
    required String sellerId,
  }) {
    return _$createProductAsyncAction.run(
      () => super.createProduct(
        name: name,
        description: description,
        pricePerSack: pricePerSack,
        stock: stock,
        category: category,
        imagePath: imagePath,
        sellerId: sellerId,
      ),
    );
  }

  late final _$updateProductAsyncAction = AsyncAction(
    '_ProductStore.updateProduct',
    context: context,
  );

  @override
  Future<void> updateProduct(ProductModel product) {
    return _$updateProductAsyncAction.run(() => super.updateProduct(product));
  }

  late final _$deleteProductAsyncAction = AsyncAction(
    '_ProductStore.deleteProduct',
    context: context,
  );

  @override
  Future<void> deleteProduct(String productId) {
    return _$deleteProductAsyncAction.run(() => super.deleteProduct(productId));
  }

  late final _$_ProductStoreActionController = ActionController(
    name: '_ProductStore',
    context: context,
  );

  @override
  void setSelectedCategory(ProductCategory? category) {
    final _$actionInfo = _$_ProductStoreActionController.startAction(
      name: '_ProductStore.setSelectedCategory',
    );
    try {
      return super.setSelectedCategory(category);
    } finally {
      _$_ProductStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
products: ${products},
selectedCategory: ${selectedCategory},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
filteredProducts: ${filteredProducts}
    ''';
  }
}
