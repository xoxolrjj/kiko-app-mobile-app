import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kiko_app_mobile_app/core/stores/auth_store.dart';
import 'package:kiko_app_mobile_app/firebase_options.dart';
import 'package:kiko_app_mobile_app/router.dart';
import 'package:kiko_app_mobile_app/core/stores/product_store.dart';
import 'package:kiko_app_mobile_app/core/stores/seller_store.dart';
import 'package:kiko_app_mobile_app/core/stores/admin_store.dart';
import 'package:provider/provider.dart';
import 'dependency/dependency_manager.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase once
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await DependencyManager().initialize();

    final authStore = sl<AuthStore>();
    await authStore.initialize();

    runApp(
      MyApp(
        authStore: authStore,
        productStore: sl<ProductStore>(),
        sellerStore: sl<SellerStore>(),
        adminStore: sl<AdminStore>(),
      ),
    );
  } catch (e) {
    debugPrint('Error initializing app: $e');
  }
}

class MyApp extends StatelessWidget {
  final AuthStore authStore;
  final ProductStore productStore;
  final SellerStore sellerStore;
  final AdminStore adminStore;

  const MyApp({
    super.key,
    required this.authStore,
    required this.productStore,
    required this.sellerStore,
    required this.adminStore,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthStore>.value(value: authStore),
        Provider<ProductStore>.value(value: productStore),
        //      Provider<NotificationStore>.value(value: notificationStore),
        Provider<SellerStore>.value(value: sellerStore),
        Provider<AdminStore>.value(value: adminStore),
      ],
      child: MaterialApp.router(
        routerConfig: goRouter,
        title: 'Kiko App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
      ),
    );
  }
}
