import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:kiko_app_mobile_app/core/models/notification_model.dart';
import 'package:kiko_app_mobile_app/core/stores/auth_store.dart';
import 'package:kiko_app_mobile_app/core/stores/notification_store.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final authStore = Provider.of<AuthStore>(context);
    final userId = authStore.currentUser?.id;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: const Center(child: Text('Please log in to view notifications')),
      );
    }

    final notificationStore = NotificationStore();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () => notificationStore.markAllAsRead(userId),
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: notificationStore.getNotifications(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _NotificationCard(
                notification: notification,
                onTap: () {
                  notificationStore.markAsRead(notification.id);
                  _handleNotificationTap(context, notification);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) {
    switch (notification.type) {
      case NotificationType.sellerApproval:
        context.go('/profile');
        break;
      case NotificationType.orderPlaced:
      case NotificationType.orderShipped:
      case NotificationType.orderDelivered:
      case NotificationType.orderCancelled:
      case NotificationType.orderAccepted:
      case NotificationType.orderPreparing:
      case NotificationType.orderReceived:
        if (notification.orderId != null) {
          context.go('/my-orders');
        }
        break;
      case NotificationType.accountRestricted:
        context.go('/profile');
        break;
      case NotificationType.newOrder:
        if (notification.orderId != null) {
          context.go('/seller/orders');
        }
        break;
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.isRead ? 0 : 2,
      color: notification.isRead ? Colors.grey[50] : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _getNotificationIcon(notification.type),
                color: _getNotificationColor(notification.type),
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight:
                            notification.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(notification.createdAt),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.sellerApproval:
        return Icons.store;
      case NotificationType.orderPlaced:
        return Icons.shopping_cart;
      case NotificationType.orderShipped:
        return Icons.local_shipping;
      case NotificationType.orderDelivered:
        return Icons.check_circle;
      case NotificationType.accountRestricted:
        return Icons.block;
      case NotificationType.newOrder:
        return Icons.notifications_active;
      case NotificationType.orderCancelled:
        return Icons.cancel;
      case NotificationType.orderAccepted:
        return Icons.check_circle;
      case NotificationType.orderPreparing:
        return Icons.build;
      case NotificationType.orderReceived:
        return Icons.check_circle_outline;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.sellerApproval:
        return Colors.green;
      case NotificationType.orderPlaced:
        return Colors.blue;
      case NotificationType.orderShipped:
        return Colors.orange;
      case NotificationType.orderDelivered:
        return Colors.teal;
      case NotificationType.accountRestricted:
        return Colors.red;
      case NotificationType.newOrder:
        return Colors.purple;
      case NotificationType.orderCancelled:
        return Colors.red;
      case NotificationType.orderAccepted:
        return Colors.green;
      case NotificationType.orderPreparing:
        return Colors.orange;
      case NotificationType.orderReceived:
        return Colors.teal;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
