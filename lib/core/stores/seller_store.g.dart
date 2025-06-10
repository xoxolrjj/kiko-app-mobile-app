// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SellerStore on _SellerStore, Store {
  late final _$isLoadingAtom = Atom(
    name: '_SellerStore.isLoading',
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
    name: '_SellerStore.errorMessage',
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

  late final _$sellerCountAtom = Atom(
    name: '_SellerStore.sellerCount',
    context: context,
  );

  @override
  int get sellerCount {
    _$sellerCountAtom.reportRead();
    return super.sellerCount;
  }

  @override
  set sellerCount(int value) {
    _$sellerCountAtom.reportWrite(value, super.sellerCount, () {
      super.sellerCount = value;
    });
  }

  late final _$biometricCheckAvailableAtom = Atom(
    name: '_SellerStore.biometricCheckAvailable',
    context: context,
  );

  @override
  bool get biometricCheckAvailable {
    _$biometricCheckAvailableAtom.reportRead();
    return super.biometricCheckAvailable;
  }

  @override
  set biometricCheckAvailable(bool value) {
    _$biometricCheckAvailableAtom.reportWrite(
      value,
      super.biometricCheckAvailable,
      () {
        super.biometricCheckAvailable = value;
      },
    );
  }

  late final _$biometricAuthenticatedAtom = Atom(
    name: '_SellerStore.biometricAuthenticated',
    context: context,
  );

  @override
  bool get biometricAuthenticated {
    _$biometricAuthenticatedAtom.reportRead();
    return super.biometricAuthenticated;
  }

  @override
  set biometricAuthenticated(bool value) {
    _$biometricAuthenticatedAtom.reportWrite(
      value,
      super.biometricAuthenticated,
      () {
        super.biometricAuthenticated = value;
      },
    );
  }

  late final _$availableBiometricsAtom = Atom(
    name: '_SellerStore.availableBiometrics',
    context: context,
  );

  @override
  List<BiometricType> get availableBiometrics {
    _$availableBiometricsAtom.reportRead();
    return super.availableBiometrics;
  }

  @override
  set availableBiometrics(List<BiometricType> value) {
    _$availableBiometricsAtom.reportWrite(value, super.availableBiometrics, () {
      super.availableBiometrics = value;
    });
  }

  late final _$initializeBiometricsAsyncAction = AsyncAction(
    '_SellerStore.initializeBiometrics',
    context: context,
  );

  @override
  Future<void> initializeBiometrics() {
    return _$initializeBiometricsAsyncAction.run(
      () => super.initializeBiometrics(),
    );
  }

  late final _$authenticateWithBiometricsAsyncAction = AsyncAction(
    '_SellerStore.authenticateWithBiometrics',
    context: context,
  );

  @override
  Future<bool> authenticateWithBiometrics() {
    return _$authenticateWithBiometricsAsyncAction.run(
      () => super.authenticateWithBiometrics(),
    );
  }

  late final _$loadSellerCountAsyncAction = AsyncAction(
    '_SellerStore.loadSellerCount',
    context: context,
  );

  @override
  Future<void> loadSellerCount() {
    return _$loadSellerCountAsyncAction.run(() => super.loadSellerCount());
  }

  late final _$submitSellerVerificationRequestAsyncAction = AsyncAction(
    '_SellerStore.submitSellerVerificationRequest',
    context: context,
  );

  @override
  Future<void> submitSellerVerificationRequest({
    required String businessName,
    required String businessType,
    required String shopName,
    required String contactNumber,
    required String shopLocation,
    required String businessAddress,
    required PhilippineIDType idType,
    required String idNumber,
    required String idImagePath,
    required String faceImagePath,
    required UserModel currentUser,
  }) {
    return _$submitSellerVerificationRequestAsyncAction.run(
      () => super.submitSellerVerificationRequest(
        businessName: businessName,
        businessType: businessType,
        shopName: shopName,
        contactNumber: contactNumber,
        shopLocation: shopLocation,
        businessAddress: businessAddress,
        idType: idType,
        idNumber: idNumber,
        idImagePath: idImagePath,
        faceImagePath: faceImagePath,
        currentUser: currentUser,
      ),
    );
  }

  late final _$getVerificationStatusAsyncAction = AsyncAction(
    '_SellerStore.getVerificationStatus',
    context: context,
  );

  @override
  Future<SellerVerificationRequest?> getVerificationStatus(String userId) {
    return _$getVerificationStatusAsyncAction.run(
      () => super.getVerificationStatus(userId),
    );
  }

  late final _$registerSellerAsyncAction = AsyncAction(
    '_SellerStore.registerSeller',
    context: context,
  );

  @override
  Future<void> registerSeller({
    required String shopName,
    required String contactNumber,
    required String shopLocation,
    required String idImagePath,
    required String faceImagePath,
  }) {
    return _$registerSellerAsyncAction.run(
      () => super.registerSeller(
        shopName: shopName,
        contactNumber: contactNumber,
        shopLocation: shopLocation,
        idImagePath: idImagePath,
        faceImagePath: faceImagePath,
      ),
    );
  }

  late final _$_SellerStoreActionController = ActionController(
    name: '_SellerStore',
    context: context,
  );

  @override
  void incrementSellerCount() {
    final _$actionInfo = _$_SellerStoreActionController.startAction(
      name: '_SellerStore.incrementSellerCount',
    );
    try {
      return super.incrementSellerCount();
    } finally {
      _$_SellerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void decrementSellerCount() {
    final _$actionInfo = _$_SellerStoreActionController.startAction(
      name: '_SellerStore.decrementSellerCount',
    );
    try {
      return super.decrementSellerCount();
    } finally {
      _$_SellerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setupSellerCountListener() {
    final _$actionInfo = _$_SellerStoreActionController.startAction(
      name: '_SellerStore.setupSellerCountListener',
    );
    try {
      return super.setupSellerCountListener();
    } finally {
      _$_SellerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearError() {
    final _$actionInfo = _$_SellerStoreActionController.startAction(
      name: '_SellerStore.clearError',
    );
    try {
      return super.clearError();
    } finally {
      _$_SellerStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
errorMessage: ${errorMessage},
sellerCount: ${sellerCount},
biometricCheckAvailable: ${biometricCheckAvailable},
biometricAuthenticated: ${biometricAuthenticated},
availableBiometrics: ${availableBiometrics}
    ''';
  }
}
