import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:kiko_app_mobile_app/core/stores/auth_store.dart';
import 'package:kiko_app_mobile_app/core/stores/seller_store.dart';
import 'package:kiko_app_mobile_app/core/stores/admin_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  void initState() {
    super.initState();
     WidgetsBinding.instance.addPostFrameCallback((_) {
      final sellerStore = Provider.of<SellerStore>(context, listen: false);
    //  final adminStore = Provider.of<AdminStore>(context, listen: false);

      sellerStore.setupSellerCountListener();

      //  adminStore
      //     .ensureAdminUsersExist()
      //     .then((_) {
      //        adminStore.checkAdminNotificationSystem();
      //     })
      //     .catchError((error) {
      //       debugPrint(
      //         'Failed to initialize admin notification system: $error',
      //       );
      //     });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authStore = Provider.of<AuthStore>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.signOut),
            onPressed: () {
              authStore.signOut().then((_) {
                if (context.mounted) {
                  context.go('/login');
                }
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, Admin!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              // const SizedBox(height: 8),
              // Text(
              //   'Manage your platform efficiently',
              //   style: Theme.of(
              //     context,
              //   ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              // ),
              const SizedBox(height: 32),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _AdminCard(
                    title: 'Delivery Approval',
                    subtitle: 'Manage deliveries',
                    icon: Icons.local_shipping,
                    color: Colors.blue,
                    onTap: () => context.go('/admin/deliveries'),
                  ),
                  _AdminCard(
                    title: 'Upload Banner',
                    subtitle: 'Update home banner',
                    icon: Icons.image,
                    color: Colors.purple,
                    onTap: () => context.go('/admin/banner'),
                  ),
                  _AdminCard(
                    title: 'Seller Requests',
                    subtitle: 'Review applications',
                    icon: Icons.store,
                    color: Colors.green,
                    onTap: () => context.go('/admin/seller-requests'),
                  ),
                  _AdminCard(
                    title: 'User Info',
                    subtitle: 'Manage users',
                    icon: Icons.people,
                    color: Colors.orange,
                    onTap: () => context.go('/admin/users'),
                  ),
                  _AdminCard(
                    title: 'Product Management',
                    subtitle: 'View seller products',
                    icon: Icons.inventory,
                    color: Colors.teal,
                    onTap: () => context.go('/admin/products'),
                  ),
                  _AdminCard(
                    title: 'Apology Messages',
                    subtitle: 'Review seller appeals',
                    icon: Icons.support_agent,
                    color: Colors.deepPurple,
                    onTap: () => context.go('/admin/apology-messages'),
                  ),
                  _AdminCard(
                    title: 'Notifications',
                    subtitle: 'Order alerts & updates',
                    icon: Icons.notifications,
                    color: Colors.purple,
                    onTap: () => context.go('/admin/notifications'),
                  ),
                  // _AdminCard(
                  //   title: 'Communication',
                  //   subtitle: 'Message users',
                  //   icon: Icons.message,
                  //   color: Colors.teal,
                  //   onTap: () => context.go('/admin/communication'),
                  // ),
                  // _AdminCard(
                  //   title: 'Notifications',
                  //   subtitle: 'System alerts',
                  //   icon: Icons.notifications,
                  //   color: Colors.purple,
                  //   onTap: () => context.go('/admin/notifications'),
                  // ),
                ],
              ),
              const SizedBox(height: 32),
              _buildQuickStatsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsSection(BuildContext context) {
    final authStore = Provider.of<AuthStore>(context);
    final userCount = authStore.users.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total Users',
                value: userCount.toString(),
                icon: Icons.people,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Observer(
                builder: (context) {
                  final sellerStore = Provider.of<SellerStore>(context);
                  return _StatCard(
                    title: 'Active Sellers',
                    value: sellerStore.sellerCount.toString(),
                    icon: Icons.store,
                    color: Colors.green,
                  );
                },
              ),
            ),
          ],
        ),
        // const SizedBox(height: 12),
        // Row(
        //   children: [
        //     Expanded(
        //       child: StreamBuilder<QuerySnapshot>(
        //         stream:
        //             FirebaseFirestore.instance
        //                 .collection('orders')
        //                 .where('status', isEqualTo: 'pending')
        //                 .snapshots(),
        //         builder: (context, snapshot) {
        //           final pendingOrders =
        //               snapshot.hasData ? snapshot.data!.docs.length : 0;
        //           return _StatCard(
        //             title: 'Pending Orders',
        //             value: pendingOrders.toString(),
        //             icon: Icons.pending_actions,
        //             color: Colors.orange,
        //           );
        //         },
        //       ),
        //     ),
        //     const SizedBox(width: 12),
        //     Expanded(
        //       child: StreamBuilder<QuerySnapshot>(
        //         stream:
        //             FirebaseFirestore.instance
        //                 .collection('notifications')
        //                 .where('isRead', isEqualTo: false)
        //                 .snapshots(),
        //         builder: (context, snapshot) {
        //           final unreadNotifications =
        //               snapshot.hasData ? snapshot.data!.docs.length : 0;
        //           return _StatCard(
        //             title: 'Unread Notifications',
        //             value: unreadNotifications.toString(),
        //             icon: Icons.notifications,
        //             color: Colors.red,
        //           );
        //         },
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }
}

class _AdminCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AdminCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        elevation: 6,
        shadowColor: color.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.8), color],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 32, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
