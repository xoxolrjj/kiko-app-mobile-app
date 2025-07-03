import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kiko_app_mobile_app/dependency/dependency_manager.dart';
import 'package:kiko_app_mobile_app/router.dart';
import 'package:mobx/mobx.dart';
import '../models/user_model.dart';
import '../models/admin_model.dart';
import '../models/notification_model.dart';
import 'notification_store.dart';

part 'auth_store.g.dart';

class AuthStore = _AuthStore with _$AuthStore;

abstract class _AuthStore with Store {
  late FirebaseAuth _auth;
  final FirebaseFirestore _firestore = sl<FirebaseFirestore>();

  _AuthStore() {
    _auth = sl<FirebaseAuth>();
    initialize();
  }

  @observable
  UserModel? currentUser;

  @observable
  AdminModel? currentAdmin;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  UserModel? account;

  @observable
  ObservableList<UserModel> users = ObservableList<UserModel>();

  @computed
  bool get isAuthenticated => currentUser != null || currentAdmin != null;

  @computed
  bool get isAdmin => currentAdmin != null;

  @computed
  bool get isSeller => currentUser?.role == UserRole.seller;

  // Password validation regex
  final _passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$',
  );

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!_passwordRegex.hasMatch(password)) {
      return 'Password must contain at least one letter, one number, and one special character';
    }
    return null;
  }

  @action
  Future<void> initialize() async {
    try {
      isLoading = true;
      errorMessage = null;

      // Check if user is already authenticated
      final currentFirebaseUser = _auth.currentUser;
      if (currentFirebaseUser != null) {
        await fetchUsers();
        await getUserData(currentFirebaseUser.uid);

        // Also check if this user might be an admin
        await _checkIfUserIsAdmin(currentFirebaseUser.email ?? '');
      }

      // Listen for auth state changes
      _auth.authStateChanges().listen((user) async {
        if (user != null) {
          await fetchUsers();
          await getUserData(user.uid);
          await _checkIfUserIsAdmin(user.email ?? '');
        } else {
          currentUser = null;
          currentAdmin = null;
        }
        // Refresh router when authentication state changes
        AuthRefreshNotifier().refresh();
      });
    } catch (e) {
      errorMessage = 'Error initializing auth store: $e';
      debugPrint('Error initializing auth store: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> getUserData(String uid) async {
    try {
      isLoading = true;
      errorMessage = null;

      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (!docSnapshot.exists) {
        errorMessage = 'User data not found';
        currentUser = null;
        return;
      }

      currentUser = UserModel.fromSnapshot(docSnapshot);
      // Router refresh is handled by auth state listener
    } catch (e) {
      errorMessage = 'Failed to get user data';
      debugPrint('Error getting user data: $e');
      currentUser = null;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> fetchUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();

      final usersList =
          snapshot.docs
              .map((doc) => UserModel.fromSnapshot(doc))
              .where((user) => user.id.isNotEmpty)
              .toList();

      users.clear();
      users.addAll(usersList);
    } catch (e) {
      debugPrint('Error fetching users: $e');
      errorMessage = 'Failed to fetch users';
    }
  }

  @action
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
  }) async {
    isLoading = true;
    errorMessage = null;

    try {
      // Validate required fields
      if (name.isEmpty) {
        errorMessage = 'Account name is required';
        return null;
      }

      // Validate email
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        errorMessage = 'Please enter a valid email address';
        return null;
      }

      // Validate password
      final passwordError = _validatePassword(password);
      if (passwordError != null) {
        errorMessage = passwordError;
        return null;
      }

      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        errorMessage = 'Failed to create account';
        return null;
      }

      // Create account document
      final docRef = _firestore
          .collection('users')
          .doc(userCredential.user!.uid);

      // Create account object
      final newAccount = UserModel(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        password: password,
        phoneNumber: phoneNumber,
        gender: gender ?? '',
        age: age ?? 0,
        photoUrl: photoUrl ?? '',
        role: role,
        isVerified: isVerified ?? false,
        createdAt: createdAt,
        location: location ?? '',
      );

      // Save to Firestore
      await docRef.set(newAccount.toJson());

      // Update local state
      account = newAccount;
      currentUser = newAccount;
      await fetchUsers(); // Refresh users list

      // Send COD notification to new user
      await _sendCODNotification(newAccount.id);

      return newAccount;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak';
          break;
        default:
          errorMessage = 'Failed to create account. Please try again';
      }
      debugPrint('Firebase Auth Error: ${e.code}');
      return null;
    } catch (e) {
      errorMessage = 'Error creating account: $e';
      debugPrint('Error creating account: $e');
      return null;
    } finally {
      isLoading = false;
    }
  }

  Future<void> _sendCODNotification(String userId) async {
    try {
      final notificationStore = NotificationStore();
      await notificationStore.createNotification(
        userId: userId,
        title: 'Welcome to Kiko App!',
        message:
            'Important: All orders are processed with Cash on Delivery (COD) payment method only. Payment is made when you receive your order.',
        type: NotificationType.accountCreated,
      );
    } catch (e) {
      debugPrint('Error sending COD notification: $e');
    }
  }

  @action
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      isLoading = true;
      errorMessage = null;

      // Validate email
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        errorMessage = 'Please enter a valid email address';
        return;
      }

      // Validate password
      if (password.isEmpty) {
        errorMessage = 'Password is required';
        return;
      }

      // Sign in with Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        errorMessage = 'Failed to sign in';
        return;
      }

      // Get user data from Firestore
      await getUserData(userCredential.user!.uid);
      // Router refresh is handled by auth state listener
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        default:
          errorMessage = 'An error occurred during sign in';
      }
      debugPrint('Firebase Auth Error: ${e.message}');
    } catch (e) {
      errorMessage = 'An unexpected error occurred';
      debugPrint('Error signing in: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (currentUser == null) {
      errorMessage = 'You must be logged in to update your password';
      return;
    }

    try {
      isLoading = true;
      errorMessage = null;

      // Validate inputs
      if (currentPassword.trim().isEmpty) {
        errorMessage = 'Current password is required';
        return;
      }

      if (newPassword.trim().isEmpty) {
        errorMessage = 'New password is required';
        return;
      }

      // Validate new password
      final passwordError = _validatePassword(newPassword.trim());
      if (passwordError != null) {
        errorMessage = passwordError;
        return;
      }

      // Check if passwords are different
      if (currentPassword.trim() == newPassword.trim()) {
        errorMessage = 'New password must be different from current password';
        return;
      }

      // Reauthenticate user
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage = 'User session expired. Please sign in again';
        return;
      }

      debugPrint('Attempting to reauthenticate user for password update');

      // Get credentials for reauthentication
      final credential = EmailAuthProvider.credential(
        email: currentUser!.email.trim(),
        password: currentPassword.trim(),
      );

      // Reauthenticate
      await user.reauthenticateWithCredential(credential);
      debugPrint('Reauthentication successful');

      // Update password
      await user.updatePassword(newPassword.trim());
      debugPrint('Password updated successfully');
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          errorMessage =
              'Current password is incorrect. Please check your password and try again.';
          break;
        case 'requires-recent-login':
          errorMessage =
              'Please sign out and sign in again to update your password';
          break;
        case 'weak-password':
          errorMessage = 'The new password is too weak';
          break;
        case 'user-mismatch':
          errorMessage = 'Authentication error. Please try signing in again.';
          break;
        case 'network-request-failed':
          errorMessage =
              'Network error. Please check your connection and try again.';
          break;
        default:
          errorMessage = 'Failed to update password: ${e.message ?? e.code}';
      }
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
    } catch (e) {
      errorMessage = 'An unexpected error occurred. Please try again';
      debugPrint('Error updating password: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> updateEmail(String currentPassword, String newEmail) async {
    if (currentUser == null) {
      errorMessage = 'You must be logged in to update your email';
      return;
    }

    try {
      isLoading = true;
      errorMessage = null;

      // Validate inputs
      if (currentPassword.trim().isEmpty) {
        errorMessage = 'Current password is required';
        return;
      }

      if (newEmail.trim().isEmpty) {
        errorMessage = 'New email is required';
        return;
      }

      // Validate email format
      if (!RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      ).hasMatch(newEmail.trim())) {
        errorMessage = 'Please enter a valid email address';
        return;
      }

      // Check if email is actually different
      if (newEmail.trim().toLowerCase() ==
          currentUser!.email.trim().toLowerCase()) {
        errorMessage = 'New email must be different from current email';
        return;
      }

      // Reauthenticate user
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage = 'User session expired. Please sign in again';
        return;
      }

      // Debug user state before attempting email update
      await debugUserState();

      debugPrint('Attempting to reauthenticate user: ${currentUser!.email}');

      // Get credentials for reauthentication - ensure we use exact current email
      final credential = EmailAuthProvider.credential(
        email: currentUser!.email.trim(),
        password: currentPassword.trim(),
      );

      // Reauthenticate first
      await user.reauthenticateWithCredential(credential);
      debugPrint('Reauthentication successful');

      try {
        // Update email in Firebase Auth
        debugPrint('Starting Firebase Auth email update...');
        await user.updateEmail(newEmail.trim());
        debugPrint('Firebase Auth email updated successfully');
      } catch (emailUpdateError) {
        debugPrint('Firebase Auth email update failed: $emailUpdateError');
        if (emailUpdateError is FirebaseAuthException) {
          debugPrint(
            'Firebase Auth email update error code: ${emailUpdateError.code}',
          );
          debugPrint(
            'Firebase Auth email update error message: ${emailUpdateError.message}',
          );
        }
        rethrow; // Re-throw to be caught by outer catch block
      }

      try {
        // Update email in Firestore
        debugPrint('Starting Firestore user email update...');
        await _firestore.collection('users').doc(currentUser!.id).update({
          'email': newEmail.trim(),
        });
        debugPrint('Firestore user email updated successfully');
      } catch (firestoreError) {
        debugPrint('Firestore user email update failed: $firestoreError');
        // Continue even if Firestore update fails, as Firebase Auth was successful
      }

      try {
        // If user is also a seller, update seller collection
        if (currentUser!.role == UserRole.seller) {
          debugPrint('Starting Firestore seller email update...');
          await _firestore.collection('sellers').doc(currentUser!.id).update({
            'email': newEmail.trim(),
          });
          debugPrint('Firestore seller email updated successfully');
        }
      } catch (sellerUpdateError) {
        debugPrint('Firestore seller email update failed: $sellerUpdateError');
        // Continue even if seller update fails
      }

      try {
        // Refresh user data
        debugPrint('Refreshing user data...');
        await getUserData(currentUser!.id);
        debugPrint('User data refreshed successfully');
      } catch (refreshError) {
        debugPrint('User data refresh failed: $refreshError');
        // Continue even if refresh fails
      }

      debugPrint('Email update process completed');
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          errorMessage =
              'Current password is incorrect. Please check your password and try again.';
          break;
        case 'email-already-in-use':
          errorMessage = 'This email is already in use by another account';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid';
          break;
        case 'requires-recent-login':
          errorMessage =
              'Please sign out and sign in again to update your email';
          break;
        case 'user-mismatch':
          errorMessage = 'Authentication error. Please try signing in again.';
          break;
        case 'network-request-failed':
          errorMessage =
              'Network error. Please check your connection and try again.';
          break;
        case 'operation-not-allowed':
          errorMessage =
              'Email updates are not allowed. Please contact support.';
          break;
        case 'too-many-requests':
          errorMessage =
              'Too many requests. Please wait a moment and try again.';
          break;
        case 'user-disabled':
          errorMessage =
              'This account has been disabled. Please contact support.';
          break;
        case 'invalid-action-code':
          errorMessage =
              'Email verification required. Please check your email.';
          break;
        default:
          errorMessage = 'Failed to update email: ${e.message ?? e.code}';
      }
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
    } catch (e) {
      errorMessage = 'An unexpected error occurred. Please try again';
      debugPrint('Error updating email: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> resetPassword(String email) async {
    try {
      isLoading = true;
      errorMessage = null;

      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        errorMessage = 'Please enter a valid email address';
        return;
      }

      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('Password reset email sent successfully');
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid';
          break;
        default:
          errorMessage =
              'Failed to send password reset email. Please try again';
      }
      debugPrint('Firebase Auth Error: ${e.code}');
    } catch (e) {
      errorMessage = 'An unexpected error occurred. Please try again';
      debugPrint('Error sending password reset email: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      currentUser = null;
      currentAdmin = null;
      isLoading = false; // Reset loading state on sign out
      errorMessage = null; // Clear any error messages
      AuthRefreshNotifier().refresh();
    } catch (e) {
      errorMessage = 'Failed to sign out';
      debugPrint('Error signing out: $e');
    }
  }

  @action
  Future<bool> signInAsAdmin(String email, String password) async {
    try {
      isLoading = true;
      errorMessage = null;

      // First, check if this is a valid admin in the admins collection
      final adminQuery =
          await _firestore
              .collection('admins')
              .where('email', isEqualTo: email)
              .where('password', isEqualTo: password)
              .where('isActive', isEqualTo: true)
              .get();

      if (adminQuery.docs.isEmpty) {
        return false; // Not a valid admin
      }

      // Admin credentials are valid, now authenticate with Firebase Auth
      try {
        // Try to sign in with Firebase Auth
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential.user != null) {
          // Successfully authenticated with Firebase Auth
          final adminDoc = adminQuery.docs.first;
          currentAdmin = AdminModel.fromSnapshot(adminDoc);
          currentUser = null; // Clear user state when admin logs in
          AuthRefreshNotifier().refresh();
          return true;
        }
      } catch (firebaseAuthError) {
        // If Firebase Auth fails, it might be because the admin account doesn't exist in Firebase Auth
        // In this case, we'll create a Firebase Auth account for the admin
        debugPrint(
          'Admin not found in Firebase Auth, creating account: $firebaseAuthError',
        );

        try {
          final userCredential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          if (userCredential.user != null) {
            // Successfully created and authenticated
            final adminDoc = adminQuery.docs.first;
            currentAdmin = AdminModel.fromSnapshot(adminDoc);
            currentUser = null; // Clear user state when admin logs in
            AuthRefreshNotifier().refresh();
            return true;
          }
        } catch (createError) {
          debugPrint(
            'Failed to create Firebase Auth account for admin: $createError',
          );
          // Fall back to the old method if Firebase Auth creation fails
          final adminDoc = adminQuery.docs.first;
          currentAdmin = AdminModel.fromSnapshot(adminDoc);
          currentUser = null; // Clear user state when admin logs in
          AuthRefreshNotifier().refresh();
          return true;
        }
      }

      return false; // Should not reach here
    } catch (e) {
      errorMessage = 'Admin login failed: $e';
      debugPrint('Error in admin login: $e');
      return false;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> updateProfile({
    String? name,
    String? photoUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    if (currentUser == null) {
      errorMessage = 'You must be logged in to update your profile';
      return;
    }

    try {
      isLoading = true;
      errorMessage = null;

      Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (photoUrl != null) data['photoUrl'] = photoUrl;
      if (additionalData != null) data.addAll(additionalData);

      await _firestore.collection('users').doc(currentUser!.id).update(data);
      await getUserData(currentUser!.id);
      await fetchUsers(); // Refresh users list
    } catch (e) {
      errorMessage = 'Failed to update profile. Please try again';
      debugPrint('Error updating profile: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> requestSellerRole() async {
    if (currentUser == null) {
      errorMessage = 'You must be logged in to request seller role';
      return;
    }

    try {
      isLoading = true;
      errorMessage = null;

      await _firestore.collection('users').doc(currentUser!.id).update({
        'role': UserRole.seller.toString(),
        'roleRequestedAt': Timestamp.now(),
      });

      await getUserData(currentUser!.id);
      await fetchUsers(); // Refresh users list
    } catch (e) {
      errorMessage = 'Failed to request seller role. Please try again';
      debugPrint('Error requesting seller role: $e');
    } finally {
      isLoading = false;
    }
  }

  // Private method to check if user is admin on app initialization
  Future<void> _checkIfUserIsAdmin(String email) async {
    try {
      if (email.isEmpty) return;

      final adminQuery =
          await _firestore
              .collection('admins')
              .where('email', isEqualTo: email)
              .where('isActive', isEqualTo: true)
              .get();

      if (adminQuery.docs.isNotEmpty) {
        final adminDoc = adminQuery.docs.first;
        currentAdmin = AdminModel.fromSnapshot(adminDoc);
        // Clear user state if admin
        currentUser = null;
        // Router refresh is handled by auth state listener
      }
    } catch (e) {
      debugPrint('Error checking admin status: $e');
    }
  }

  @action
  void clearError() {
    errorMessage = null;
  }

  // Debug method to check user state before email update
  @action
  Future<void> debugUserState() async {
    debugPrint('=== DEBUG USER STATE ===');
    debugPrint('Current Firebase User: ${_auth.currentUser?.uid}');
    debugPrint('Current Firebase User Email: ${_auth.currentUser?.email}');
    debugPrint(
      'Current Firebase User Verified: ${_auth.currentUser?.emailVerified}',
    );
    debugPrint('Current Store User: ${currentUser?.id}');
    debugPrint('Current Store User Email: ${currentUser?.email}');
    debugPrint('Current Store User Role: ${currentUser?.role}');
    debugPrint('=========================');
  }

  // Combined update method to handle email and password changes properly
  @action
  Future<void> updateEmailAndPassword({
    required String currentPassword,
    String? newEmail,
    String? newPassword,
  }) async {
    if (currentUser == null) {
      errorMessage = 'You must be logged in to update your profile';
      return;
    }

    try {
      isLoading = true;
      errorMessage = null;

      // Validate inputs
      if (currentPassword.trim().isEmpty) {
        errorMessage = 'Current password is required';
        return;
      }

      debugPrint('Starting combined email/password update...');
      await debugUserState();

      final user = _auth.currentUser;
      if (user == null) {
        errorMessage = 'User session expired. Please sign in again';
        return;
      }

      // Update email first if provided
      if (newEmail != null && newEmail.trim().isNotEmpty) {
        if (newEmail.trim().toLowerCase() !=
            currentUser!.email.trim().toLowerCase()) {
          debugPrint('Updating email first...');
          await updateEmail(currentPassword, newEmail);
          if (errorMessage != null) return;

          // Small delay to ensure Firebase processes the email change
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      // Update password second if provided
      if (newPassword != null && newPassword.trim().isNotEmpty) {
        debugPrint('Updating password second...');
        await updatePassword(currentPassword, newPassword);
        if (errorMessage != null) return;
      }

      debugPrint('Combined update completed successfully');
    } catch (e) {
      errorMessage = 'Failed to update profile. Please try again.';
      debugPrint('Error in combined update: $e');
    } finally {
      isLoading = false;
    }
  }
}
