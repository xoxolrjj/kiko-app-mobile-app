// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apology_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ApologyStore on _ApologyStore, Store {
  Computed<bool>? _$hasErrorComputed;

  @override
  bool get hasError =>
      (_$hasErrorComputed ??= Computed<bool>(
            () => super.hasError,
            name: '_ApologyStore.hasError',
          ))
          .value;

  late final _$isLoadingAtom = Atom(
    name: '_ApologyStore.isLoading',
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
    name: '_ApologyStore.errorMessage',
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

  late final _$apologyMessagesAtom = Atom(
    name: '_ApologyStore.apologyMessages',
    context: context,
  );

  @override
  ObservableList<ApologyMessageModel> get apologyMessages {
    _$apologyMessagesAtom.reportRead();
    return super.apologyMessages;
  }

  @override
  set apologyMessages(ObservableList<ApologyMessageModel> value) {
    _$apologyMessagesAtom.reportWrite(value, super.apologyMessages, () {
      super.apologyMessages = value;
    });
  }

  late final _$sendApologyMessageAsyncAction = AsyncAction(
    '_ApologyStore.sendApologyMessage',
    context: context,
  );

  @override
  Future<void> sendApologyMessage({
    required String sellerId,
    required String sellerName,
    required String sellerEmail,
    required String message,
  }) {
    return _$sendApologyMessageAsyncAction.run(
      () => super.sendApologyMessage(
        sellerId: sellerId,
        sellerName: sellerName,
        sellerEmail: sellerEmail,
        message: message,
      ),
    );
  }

  late final _$loadApologyMessagesAsyncAction = AsyncAction(
    '_ApologyStore.loadApologyMessages',
    context: context,
  );

  @override
  Future<void> loadApologyMessages() {
    return _$loadApologyMessagesAsyncAction.run(
      () => super.loadApologyMessages(),
    );
  }

  late final _$loadSellerApologyMessagesAsyncAction = AsyncAction(
    '_ApologyStore.loadSellerApologyMessages',
    context: context,
  );

  @override
  Future<void> loadSellerApologyMessages(String sellerId) {
    return _$loadSellerApologyMessagesAsyncAction.run(
      () => super.loadSellerApologyMessages(sellerId),
    );
  }

  late final _$respondToApologyAsyncAction = AsyncAction(
    '_ApologyStore.respondToApology',
    context: context,
  );

  @override
  Future<void> respondToApology({
    required String apologyId,
    required String adminResponse,
    required String reviewedBy,
    required ApologyStatus status,
  }) {
    return _$respondToApologyAsyncAction.run(
      () => super.respondToApology(
        apologyId: apologyId,
        adminResponse: adminResponse,
        reviewedBy: reviewedBy,
        status: status,
      ),
    );
  }

  late final _$_notifyAdminsAsyncAction = AsyncAction(
    '_ApologyStore._notifyAdmins',
    context: context,
  );

  @override
  Future<void> _notifyAdmins(ApologyMessageModel apologyMessage) {
    return _$_notifyAdminsAsyncAction.run(
      () => super._notifyAdmins(apologyMessage),
    );
  }

  late final _$_ApologyStoreActionController = ActionController(
    name: '_ApologyStore',
    context: context,
  );

  @override
  Stream<List<ApologyMessageModel>> getApologyMessagesStream() {
    final _$actionInfo = _$_ApologyStoreActionController.startAction(
      name: '_ApologyStore.getApologyMessagesStream',
    );
    try {
      return super.getApologyMessagesStream();
    } finally {
      _$_ApologyStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  Stream<List<ApologyMessageModel>> getSellerApologyMessagesStream(
    String sellerId,
  ) {
    final _$actionInfo = _$_ApologyStoreActionController.startAction(
      name: '_ApologyStore.getSellerApologyMessagesStream',
    );
    try {
      return super.getSellerApologyMessagesStream(sellerId);
    } finally {
      _$_ApologyStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearError() {
    final _$actionInfo = _$_ApologyStoreActionController.startAction(
      name: '_ApologyStore.clearError',
    );
    try {
      return super.clearError();
    } finally {
      _$_ApologyStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
errorMessage: ${errorMessage},
apologyMessages: ${apologyMessages},
hasError: ${hasError}
    ''';
  }
}
