import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kiko_app_mobile_app/core/stores/auth_store.dart';
 import 'package:kiko_app_mobile_app/firebase_options.dart';
import 'package:kiko_app_mobile_app/router.dart';
import 'package:kiko_app_mobile_app/core/stores/product_store.dart';
import 'package:kiko_app_mobile_app/core/stores/seller_store.dart';
import 'package:provider/provider.dart';
import 'dependency/dependency_manager.dart';

// Repositories

// Stores
 
// Screens

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

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
      ),
    );

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Error initializing app: $e');
  }
}

class MyApp extends StatelessWidget {
  final AuthStore authStore;
  final ProductStore productStore;
  final SellerStore sellerStore;

  const MyApp({
    super.key,
    required this.authStore,
    required this.productStore,
    required this.sellerStore,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthStore>.value(value: authStore),
        Provider<ProductStore>.value(value: productStore),
        //      Provider<NotificationStore>.value(value: notificationStore),
        Provider<SellerStore>.value(value: sellerStore),
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
