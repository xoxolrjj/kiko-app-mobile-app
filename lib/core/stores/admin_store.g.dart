// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AdminStore on _AdminStore, Store {
  Computed<bool>? _$hasErrorComputed;

  @override
  bool get hasError =>
      (_$hasErrorComputed ??= Computed<bool>(
            () => super.hasError,
            name: '_AdminStore.hasError',
          ))
          .value;

  late final _$isLoadingAtom = Atom(
    name: '_AdminStore.isLoading',
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
    name: '_AdminStore.errorMessage',
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

  late final _$totalUsersAtom = Atom(
    name: '_AdminStore.totalUsers',
    context: context,
  );

  @override
  int get totalUsers {
    _$totalUsersAtom.reportRead();
    return super.totalUsers;
  }

  @override
  set totalUsers(int value) {
    _$totalUsersAtom.reportWrite(value, super.totalUsers, () {
      super.totalUsers = value;
    });
  }

  late final _$activeSellersAtom = Atom(
    name: '_AdminStore.activeSellers',
    context: context,
  );

  @override
  int get activeSellers {
    _$activeSellersAtom.reportRead();
    return super.activeSellers;
  }

  @override
  set activeSellers(int value) {
    _$activeSellersAtom.reportWrite(value, super.activeSellers, () {
      super.activeSellers = value;
    });
  }

  late final _$pendingDeliveriesAtom = Atom(
    name: '_AdminStore.pendingDeliveries',
    context: context,
  );

  @override
  int get pendingDeliveries {
    _$pendingDeliveriesAtom.reportRead();
    return super.pendingDeliveries;
  }

  @override
  set pendingDeliveries(int value) {
    _$pendingDeliveriesAtom.reportWrite(value, super.pendingDeliveries, () {
      super.pendingDeliveries = value;
    });
  }

  late final _$unreadNotificationsAtom = Atom(
    name: '_AdminStore.unreadNotifications',
    context: context,
  );

  @override
  int get unreadNotifications {
    _$unreadNotificationsAtom.reportRead();
    return super.unreadNotifications;
  }

  @override
  set unreadNotifications(int value) {
    _$unreadNotificationsAtom.reportWrite(value, super.unreadNotifications, () {
      super.unreadNotifications = value;
    });
  }

  late final _$restrictedUsersAtom = Atom(
    name: '_AdminStore.restrictedUsers',
    context: context,
  );

  @override
  ObservableList<UserModel> get restrictedUsers {
    _$restrictedUsersAtom.reportRead();
    return super.restrictedUsers;
  }

  @override
  set restrictedUsers(ObservableList<UserModel> value) {
    _$restrictedUsersAtom.reportWrite(value, super.restrictedUsers, () {
      super.restrictedUsers = value;
    });
  }

  late final _$loadDashboardDataAsyncAction = AsyncAction(
    '_AdminStore.loadDashboardData',
    context: context,
  );

  @override
  Future<void> loadDashboardData() {
    return _$loadDashboardDataAsyncAction.run(() => super.loadDashboardData());
  }

  late final _$_loadUserStatsAsyncAction = AsyncAction(
    '_AdminStore._loadUserStats',
    context: context,
  );

  @override
  Future<void> _loadUserStats() {
    return _$_loadUserStatsAsyncAction.run(() => super._loadUserStats());
  }

  late final _$_loadDeliveryStatsAsyncAction = AsyncAction(
    '_AdminStore._loadDeliveryStats',
    context: context,
  );

  @override
  Future<void> _loadDeliveryStats() {
    return _$_loadDeliveryStatsAsyncAction.run(
      () => super._loadDeliveryStats(),
    );
  }

  late final _$_loadNotificationStatsAsyncAction = AsyncAction(
    '_AdminStore._loadNotificationStats',
    context: context,
  );

  @override
  Future<void> _loadNotificationStats() {
    return _$_loadNotificationStatsAsyncAction.run(
      () => super._loadNotificationStats(),
    );
  }

  late final _$_loadRestrictedUsersAsyncAction = AsyncAction(
    '_AdminStore._loadRestrictedUsers',
    context: context,
  );

  @override
  Future<void> _loadRestrictedUsers() {
    return _$_loadRestrictedUsersAsyncAction.run(
      () => super._loadRestrictedUsers(),
    );
  }

  late final _$updateUserStatusAsyncAction = AsyncAction(
    '_AdminStore.updateUserStatus',
    context: context,
  );

  @override
  Future<void> updateUserStatus(String userId, String status) {
    return _$updateUserStatusAsyncAction.run(
      () => super.updateUserStatus(userId, status),
    );
  }

  late final _$sendNotificationAsyncAction = AsyncAction(
    '_AdminStore.sendNotification',
    context: context,
  );

  @override
  Future<void> sendNotification({
    required String title,
    required String message,
    required String type,
    String? recipientType,
    String? recipientId,
  }) {
    return _$sendNotificationAsyncAction.run(
      () => super.sendNotification(
        title: title,
        message: message,
        type: type,
        recipientType: recipientType,
        recipientId: recipientId,
      ),
    );
  }

  late final _$approveSellerRequestAsyncAction = AsyncAction(
    '_AdminStore.approveSellerRequest',
    context: context,
  );

  @override
  Future<void> approveSellerRequest(
    String requestId,
    Map<String, dynamic> requestData,
  ) {
    return _$approveSellerRequestAsyncAction.run(
      () => super.approveSellerRequest(requestId, requestData),
    );
  }

  late final _$rejectSellerRequestAsyncAction = AsyncAction(
    '_AdminStore.rejectSellerRequest',
    context: context,
  );

  @override
  Future<void> rejectSellerRequest(String requestId) {
    return _$rejectSellerRequestAsyncAction.run(
      () => super.rejectSellerRequest(requestId),
    );
  }

  late final _$_AdminStoreActionController = ActionController(
    name: '_AdminStore',
    context: context,
  );

  @override
  void clearError() {
    final _$actionInfo = _$_AdminStoreActionController.startAction(
      name: '_AdminStore.clearError',
    );
    try {
      return super.clearError();
    } finally {
      _$_AdminStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void dispose() {
    final _$actionInfo = _$_AdminStoreActionController.startAction(
      name: '_AdminStore.dispose',
    );
    try {
      return super.dispose();
    } finally {
      _$_AdminStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
errorMessage: ${errorMessage},
totalUsers: ${totalUsers},
activeSellers: ${activeSellers},
pendingDeliveries: ${pendingDeliveries},
unreadNotifications: ${unreadNotifications},
restrictedUsers: ${restrictedUsers},
hasError: ${hasError}
    ''';
  }
}
