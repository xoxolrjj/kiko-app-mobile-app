import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kiko_app_mobile_app/core/stores/auth_store.dart';
import 'package:kiko_app_mobile_app/core/stores/seller_store.dart';
import 'package:kiko_app_mobile_app/core/stores/product_store.dart';
import 'package:kiko_app_mobile_app/core/stores/admin_store.dart';

final GetIt sl = GetIt.instance;

extension GetItExtension on GetIt {
  Future<void> ensureReady<T extends Object>() async {
    try {
      await isReady<T>();
    } catch (e) {
      debugPrint('$T is not registered');
    }
  }
}

class DependencyManager {
  DependencyManager() {
    provideDependencies();
  }

  Future<void> initialize() async {
    await sl.allReady();
  }

  Future<void> dispose() async {
    await sl.reset();
  }

  void provideDependencies() {
    provideFirebaseCore();
    provideAuth();
    provideFirestore();
    provideFirebaseStorage();
    setupDependencies();
  }

  void provideFirebaseCore() {
    sl.registerSingletonAsync<FirebaseApp>(() async {
      return await Firebase.initializeApp();
    });
  }

  void provideAuth() {
    sl.registerSingletonAsync<FirebaseAuth>(() async {
      return FirebaseAuth.instance;
    }, dependsOn: [FirebaseApp]);
  }

  void provideFirestore() {
    sl.registerSingletonAsync<FirebaseFirestore>(() async {
      return FirebaseFirestore.instance;
    }, dependsOn: [FirebaseApp]);
  }

  void provideFirebaseStorage() {
    sl.registerSingletonAsync<FirebaseStorage>(() async {
      return FirebaseStorage.instance;
    }, dependsOn: [FirebaseApp]);
  }

  void setupDependencies() {
    // Register Firebase Messaging
    sl.registerLazySingleton<FirebaseMessaging>(
      () => FirebaseMessaging.instance,
    );

    // Register Device Info Plugin
    sl.registerLazySingleton<DeviceInfoPlugin>(() => DeviceInfoPlugin());

    // Register Stores
    sl.registerLazySingleton(() => AuthStore());
    sl.registerLazySingleton(() => ProductStore());
    sl.registerLazySingleton(() => SellerStore());
    sl.registerLazySingleton(() => AdminStore());
  }
}
