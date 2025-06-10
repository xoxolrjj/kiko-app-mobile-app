import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kiko_app_mobile_app/core/models/conversation_model.dart';
import 'package:kiko_app_mobile_app/core/stores/auth_store.dart';
import 'package:provider/provider.dart';
import 'package:kiko_app_mobile_app/core/models/product_model.dart';
import 'package:kiko_app_mobile_app/screen/auth/screens/login_screen.dart';
import 'package:kiko_app_mobile_app/screen/auth/screens/register_screen.dart';
import 'package:kiko_app_mobile_app/screen/home/screens/home_screen.dart';
import 'package:kiko_app_mobile_app/screen/products/screens/product_details_screen.dart';
import 'package:kiko_app_mobile_app/screen/products/screens/product_screen.dart';
import 'package:kiko_app_mobile_app/screen/messaging/screens/message_screen.dart';
import 'package:kiko_app_mobile_app/screen/products/widgets/create_product.dart';
import 'package:kiko_app_mobile_app/screen/profile/screens/profile_screen.dart';
import 'package:kiko_app_mobile_app/screen/seller/screens/become_a_seller.dart';
import 'package:kiko_app_mobile_app/screen/seller/screens/seller_products_screen.dart';
import 'package:kiko_app_mobile_app/screen/seller/screens/seller_orders_screen.dart';
import 'package:kiko_app_mobile_app/screen/admin/screens/admin_screen.dart';
import 'package:kiko_app_mobile_app/screen/admin/screens/delivery_approval_screen.dart';
import 'package:kiko_app_mobile_app/screen/admin/screens/seller_requests_screen.dart';
import 'package:kiko_app_mobile_app/screen/admin/screens/user_management_screen.dart';
import 'package:kiko_app_mobile_app/screen/admin/screens/notifications_screen.dart';
import 'package:kiko_app_mobile_app/screen/admin/screens/admin_communication_screen.dart';
import 'package:kiko_app_mobile_app/screen/checkout/screens/checkout_screen.dart';
import 'package:kiko_app_mobile_app/screen/orders/screens/my_orders_screen.dart';
import 'package:kiko_app_mobile_app/screen/messaging/screens/conversation_detail_screen.dart';
import 'package:kiko_app_mobile_app/screen/seller/screens/seller_message_screen.dart';
import 'package:kiko_app_mobile_app/core/models/user_model.dart';
import 'package:kiko_app_mobile_app/screen/admin/screens/banner_management_screen.dart';
import 'package:kiko_app_mobile_app/screen/notifications/screens/notifications_screen.dart'
    as user_notifications;
import 'package:kiko_app_mobile_app/core/stores/notification_store.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

// Notifier to refresh router when authentication state changes
class AuthRefreshNotifier extends ChangeNotifier {
  static final AuthRefreshNotifier _instance = AuthRefreshNotifier._internal();
  factory AuthRefreshNotifier() => _instance;
  AuthRefreshNotifier._internal();

  Timer? _debounceTimer;

  void refresh() {
    // Debounce the refresh to avoid multiple simultaneous navigation operations
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  refreshListenable: AuthRefreshNotifier(),
  redirect: (context, state) {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    final currentLocation = state.uri.path;

    // Public routes that don't require authentication
    final publicRoutes = ['/login', '/register'];
    final isPublicRoute = publicRoutes.contains(currentLocation);

    // Admin routes
    final isAdminRoute = currentLocation.startsWith('/admin');

    // Check authentication state
    final isAuthenticated = authStore.isAuthenticated;
    final isAdmin = authStore.isAdmin;

    // If not authenticated and trying to access protected route
    if (!isAuthenticated && !isPublicRoute) {
      return '/login';
    }

    // If authenticated and trying to access login/register, redirect to home
    if (isAuthenticated && isPublicRoute) {
      return isAdmin ? '/admin' : '/home';
    }

    // If non-admin trying to access admin routes
    if (isAdminRoute && !isAdmin) {
      return '/home';
    }

    return null; // No redirect needed
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/become-a-seller',
      builder: (context, state) => const BecomeASeller(),
    ),
    GoRoute(
      path: '/notifications',
      builder:
          (context, state) => const user_notifications.NotificationsScreen(),
    ),

    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    GoRoute(
      path: '/product-details',
      builder: (context, state) {
        final product = state.extra as ProductModel?;

        return ProductDetailsScreen(product: product!);
      },
    ),

    GoRoute(
      path: '/create-product',
      builder: (context, state) => const CreateProduct(),
    ),

    GoRoute(
      path: '/edit-product',
      builder: (context, state) {
        final product = state.extra as ProductModel?;
        return CreateProduct(productToEdit: product);
      },
    ),

    // Seller routes
    GoRoute(
      path: '/seller/products',
      builder: (context, state) => const SellerProductsScreen(),
    ),
    GoRoute(
      path: '/seller/orders',
      builder: (context, state) => const SellerOrdersScreen(),
    ),

    // Checkout and Orders routes
    GoRoute(
      path: '/checkout',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return CheckoutScreen(
          product: extra['product'] as ProductModel,
          quantity: extra['quantity'] as int,
          sellerData: extra['sellerData'] as Map<String, dynamic>,
        );
      },
    ),
    GoRoute(
      path: '/my-orders',
      builder: (context, state) => const MyOrdersScreen(),
    ),

    // Messages routes
    // GoRoute(
    //   path: '/messages',
    //   builder: (context, state) => const MessageScreen(),
    // ),
    GoRoute(
      path: '/seller/messages',
      builder: (context, state) => const SellerMessageScreen(),
    ),
    GoRoute(
      path: '/conversation',
      builder: (context, state) {
        final conversation = state.extra as ConversationModel;
        return ConversationDetailScreen(conversation: conversation);
      },
    ),

    // Admin routes
    GoRoute(path: '/admin', builder: (context, state) => const AdminScreen()),
    GoRoute(
      path: '/admin/deliveries',
      builder: (context, state) => const DeliveryApprovalScreen(),
    ),
    GoRoute(
      path: '/admin/banner',
      builder: (context, state) => const BannerManagementScreen(),
    ),
    GoRoute(
      path: '/admin/seller-requests',
      builder: (context, state) => const SellerRequestsScreen(),
    ),
    GoRoute(
      path: '/admin/users',
      builder: (context, state) => const UserManagementScreen(),
    ),
    GoRoute(
      path: '/admin/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/admin/communication',
      builder: (context, state) => const AdminCommunicationScreen(),
    ),

    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _calculateSelectedIndex(context),
            onDestinationSelected: (int idx) => _onItemTapped(idx, context),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.shopping_bag_outlined),
                selectedIcon: Icon(Icons.shopping_bag),
                label: 'Products',
              ),
              NavigationDestination(
                icon: Icon(Icons.message_outlined),
                selectedIcon: Icon(Icons.message),
                label: 'Messages',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/products',
          builder: (context, state) => const ProductScreen(),
        ),
        GoRoute(
          path: '/messages',
          builder: (context, state) {
            final authStore = Provider.of<AuthStore>(context);
            if (authStore.currentUser?.role == UserRole.seller) {
              return const SellerMessageScreen();
            }
            return const MessageScreen();
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);

int _calculateSelectedIndex(BuildContext context) {
  final String location = GoRouterState.of(context).uri.path;

  if (location.startsWith('/products')) return 1;
  if (location.startsWith('/messages')) return 2;
  if (location.startsWith('/profile')) return 3;
  return 0;
}

void _onItemTapped(int index, BuildContext context) {
  print('Navigating to tab index: $index');

  switch (index) {
    case 0:
      GoRouter.of(context).go('/home');
      break;
    case 1:
      GoRouter.of(context).go('/products');
      break;
    case 2:
      GoRouter.of(context).go('/messages');
      break;
    case 3:
      GoRouter.of(context).go('/profile');
      break;
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;

  const _AppBar({
    required this.title,
    this.showBackButton = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final authStore = Provider.of<AuthStore>(context);
    final user = authStore.currentUser;
    final notificationStore = NotificationStore();

    return AppBar(
      title: Text(title),
      leading:
          showBackButton
              ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/'),
              )
              : null,
      actions: [
        if (user != null) ...[
          StreamBuilder<int>(
            stream: Stream.periodic(
              const Duration(seconds: 30),
            ).asyncMap((_) => notificationStore.getUnreadCount(user.id)),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () => context.go('/notifications'),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          if (actions != null) ...actions!,
        ],
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
