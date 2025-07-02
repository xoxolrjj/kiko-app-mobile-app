// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AuthStore on _AuthStore, Store {
  Computed<bool>? _$isAuthenticatedComputed;

  @override
  bool get isAuthenticated =>
      (_$isAuthenticatedComputed ??= Computed<bool>(
            () => super.isAuthenticated,
            name: '_AuthStore.isAuthenticated',
          ))
          .value;
  Computed<bool>? _$isAdminComputed;

  @override
  bool get isAdmin =>
      (_$isAdminComputed ??= Computed<bool>(
            () => super.isAdmin,
            name: '_AuthStore.isAdmin',
          ))
          .value;
  Computed<bool>? _$isSellerComputed;

  @override
  bool get isSeller =>
      (_$isSellerComputed ??= Computed<bool>(
            () => super.isSeller,
            name: '_AuthStore.isSeller',
          ))
          .value;

  late final _$currentUserAtom = Atom(
    name: '_AuthStore.currentUser',
    context: context,
  );

  @override
  UserModel? get currentUser {
    _$currentUserAtom.reportRead();
    return super.currentUser;
  }

  @override
  set currentUser(UserModel? value) {
    _$currentUserAtom.reportWrite(value, super.currentUser, () {
      super.currentUser = value;
    });
  }

  late final _$currentAdminAtom = Atom(
    name: '_AuthStore.currentAdmin',
    context: context,
  );

  @override
  AdminModel? get currentAdmin {
    _$currentAdminAtom.reportRead();
    return super.currentAdmin;
  }

  @override
  set currentAdmin(AdminModel? value) {
    _$currentAdminAtom.reportWrite(value, super.currentAdmin, () {
      super.currentAdmin = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: '_AuthStore.isLoading',
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
    name: '_AuthStore.errorMessage',
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

  late final _$accountAtom = Atom(name: '_AuthStore.account', context: context);

  @override
  UserModel? get account {
    _$accountAtom.reportRead();
    return super.account;
  }

  @override
  set account(UserModel? value) {
    _$accountAtom.reportWrite(value, super.account, () {
      super.account = value;
    });
  }

  late final _$usersAtom = Atom(name: '_AuthStore.users', context: context);

  @override
  ObservableList<UserModel> get users {
    _$usersAtom.reportRead();
    return super.users;
  }

  @override
  set users(ObservableList<UserModel> value) {
    _$usersAtom.reportWrite(value, super.users, () {
      super.users = value;
    });
  }

  late final _$initializeAsyncAction = AsyncAction(
    '_AuthStore.initialize',
    context: context,
  );

  @override
  Future<void> initialize() {
    return _$initializeAsyncAction.run(() => super.initialize());
  }

  late final _$getUserDataAsyncAction = AsyncAction(
    '_AuthStore.getUserData',
    context: context,
  );

  @override
  Future<void> getUserData(String uid) {
    return _$getUserDataAsyncAction.run(() => super.getUserData(uid));
  }

  late final _$fetchUsersAsyncAction = AsyncAction(
    '_AuthStore.fetchUsers',
    context: context,
  );

  @override
  Future<void> fetchUsers() {
    return _$fetchUsersAsyncAction.run(() => super.fetchUsers());
  }

  late final _$createAccountAsyncAction = AsyncAction(
    '_AuthStore.createAccount',
    context: context,
  );

  @override
  Future<UserModel?> createAccount({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
    String? location,
    String? gender,
    int? age,
    String? photoUrl,
    UserRole role = UserRole.user,
    bool? isVerified,
    required DateTime createdAt,
  }) {
    return _$createAccountAsyncAction.run(
      () => super.createAccount(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        location: location,
        gender: gender,
        age: age,
        photoUrl: photoUrl,
        role: role,
        isVerified: isVerified,
        createdAt: createdAt,
      ),
    );
  }

  late final _$signInWithEmailAndPasswordAsyncAction = AsyncAction(
    '_AuthStore.signInWithEmailAndPassword',
    context: context,
  );

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) {
    return _$signInWithEmailAndPasswordAsyncAction.run(
      () => super.signInWithEmailAndPassword(email, password),
    );
  }

  late final _$updatePasswordAsyncAction = AsyncAction(
    '_AuthStore.updatePassword',
    context: context,
  );

  @override
  Future<void> updatePassword(String currentPassword, String newPassword) {
    return _$updatePasswordAsyncAction.run(
      () => super.updatePassword(currentPassword, newPassword),
    );
  }

  late final _$updateEmailAsyncAction = AsyncAction(
    '_AuthStore.updateEmail',
    context: context,
  );

  @override
  Future<void> updateEmail(String currentPassword, String newEmail) {
    return _$updateEmailAsyncAction.run(
      () => super.updateEmail(currentPassword, newEmail),
    );
  }

  late final _$resetPasswordAsyncAction = AsyncAction(
    '_AuthStore.resetPassword',
    context: context,
  );

  @override
  Future<void> resetPassword(String email) {
    return _$resetPasswordAsyncAction.run(() => super.resetPassword(email));
  }

  late final _$signOutAsyncAction = AsyncAction(
    '_AuthStore.signOut',
    context: context,
  );

  @override
  Future<void> signOut() {
    return _$signOutAsyncAction.run(() => super.signOut());
  }

  late final _$signInAsAdminAsyncAction = AsyncAction(
    '_AuthStore.signInAsAdmin',
    context: context,
  );

  @override
  Future<bool> signInAsAdmin(String email, String password) {
    return _$signInAsAdminAsyncAction.run(
      () => super.signInAsAdmin(email, password),
    );
  }

  late final _$updateProfileAsyncAction = AsyncAction(
    '_AuthStore.updateProfile',
    context: context,
  );

  @override
  Future<void> updateProfile({
    String? name,
    String? photoUrl,
    Map<String, dynamic>? additionalData,
  }) {
    return _$updateProfileAsyncAction.run(
      () => super.updateProfile(
        name: name,
        photoUrl: photoUrl,
        additionalData: additionalData,
      ),
    );
  }

  late final _$requestSellerRoleAsyncAction = AsyncAction(
    '_AuthStore.requestSellerRole',
    context: context,
  );

  @override
  Future<void> requestSellerRole() {
    return _$requestSellerRoleAsyncAction.run(() => super.requestSellerRole());
  }

  late final _$debugUserStateAsyncAction = AsyncAction(
    '_AuthStore.debugUserState',
    context: context,
  );

  @override
  Future<void> debugUserState() {
    return _$debugUserStateAsyncAction.run(() => super.debugUserState());
  }

  late final _$updateEmailAndPasswordAsyncAction = AsyncAction(
    '_AuthStore.updateEmailAndPassword',
    context: context,
  );

  @override
  Future<void> updateEmailAndPassword({
    required String currentPassword,
    String? newEmail,
    String? newPassword,
  }) {
    return _$updateEmailAndPasswordAsyncAction.run(
      () => super.updateEmailAndPassword(
        currentPassword: currentPassword,
        newEmail: newEmail,
        newPassword: newPassword,
      ),
    );
  }

  late final _$_AuthStoreActionController = ActionController(
    name: '_AuthStore',
    context: context,
  );

  @override
  void clearError() {
    final _$actionInfo = _$_AuthStoreActionController.startAction(
      name: '_AuthStore.clearError',
    );
    try {
      return super.clearError();
    } finally {
      _$_AuthStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
currentUser: ${currentUser},
currentAdmin: ${currentAdmin},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
account: ${account},
users: ${users},
isAuthenticated: ${isAuthenticated},
isAdmin: ${isAdmin},
isSeller: ${isSeller}
    ''';
  }
}
