import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:kiko_app_mobile_app/core/models/notification_model.dart';
import 'package:kiko_app_mobile_app/core/stores/auth_store.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authStore = Provider.of<AuthStore>(context);
    final adminId = authStore.currentAdmin?.id;

    if (adminId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Notifications'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/admin'),
          ),
        ),
        body: const Center(
          child: Text('Please log in as admin to view notifications'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: () => _markAllAsRead(context, adminId),
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('notifications')
                .where('userId', isEqualTo: adminId)
                .orderBy('createdAt', descending: true)
                .snapshots(),
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
                    onPressed: () => context.go('/admin'),
                    child: const Text('Back to Admin Panel'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data?.docs ?? [];

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
                  const SizedBox(height: 8),
                  Text(
                    'You will receive notifications about order completions and other admin alerts here.',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notificationData =
                  notifications[index].data() as Map<String, dynamic>;
              final notification = NotificationModel.fromJson({
                'id': notifications[index].id,
                ...notificationData,
              });

              return _AdminNotificationCard(
                notification: notification,
                onMarkAsRead:
                    () => _markAsRead(context, notifications[index].id),
                onTap: () => _handleNotificationTap(context, notification),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _markAsRead(BuildContext context, String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true, 'updatedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error marking notification as read: $e')),
        );
      }
    }
  }

  Future<void> _markAllAsRead(BuildContext context, String adminId) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final notifications =
          await FirebaseFirestore.instance
              .collection('notifications')
              .where('userId', isEqualTo: adminId)
              .where('isRead', isEqualTo: false)
              .get();

      for (var doc in notifications.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications marked as read')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error marking all notifications as read: $e'),
          ),
        );
      }
    }
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) {
    // Handle different notification types
    switch (notification.type) {
      case NotificationType.orderReceived:
      case NotificationType.orderShipped:
      case NotificationType.orderDelivered:
      case NotificationType.orderCancelled:
        // Navigate to admin deliveries for order-related notifications
        context.go('/admin/deliveries');
        break;
      case NotificationType.newOrder:
        // Navigate to delivery approval screen
        context.go('/admin/deliveries');
        break;
      case NotificationType.sellerApology:
        // Navigate to apology management
        context.go('/admin/apology-messages');
        break;
      default:
        // Stay on notifications screen for other types
        break;
    }
  }
}

class _AdminNotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onMarkAsRead;
  final VoidCallback onTap;

  const _AdminNotificationCard({
    required this.notification,
    required this.onMarkAsRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: notification.isRead ? 1 : 3,
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            onMarkAsRead();
          }
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getNotificationColor(
                        notification.type,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: _getNotificationColor(notification.type),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight:
                                notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getNotificationTypeLabel(notification.type),
                          style: TextStyle(
                            color: _getNotificationColor(notification.type),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
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
              const SizedBox(height: 12),
              Text(
                notification.message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      notification.isRead
                          ? Colors.grey.shade700
                          : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(notification.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (notification.orderId != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Order #${notification.orderId!.substring(0, 8)}',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.orderReceived:
        return Icons.check_circle;
      case NotificationType.orderShipped:
        return Icons.local_shipping;
      case NotificationType.orderDelivered:
        return Icons.done_all;
      case NotificationType.orderCancelled:
        return Icons.cancel;
      case NotificationType.newOrder:
        return Icons.shopping_bag;
      case NotificationType.sellerApology:
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.orderReceived:
        return Colors.green;
      case NotificationType.orderShipped:
        return Colors.blue;
      case NotificationType.orderDelivered:
        return Colors.teal;
      case NotificationType.orderCancelled:
        return Colors.red;
      case NotificationType.newOrder:
        return Colors.orange;
      case NotificationType.sellerApology:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getNotificationTypeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.orderReceived:
        return 'ORDER COMPLETED';
      case NotificationType.orderShipped:
        return 'ORDER SHIPPED';
      case NotificationType.orderDelivered:
        return 'ORDER DELIVERED';
      case NotificationType.orderCancelled:
        return 'ORDER CANCELLED';
      case NotificationType.newOrder:
        return 'NEW ORDER';
      case NotificationType.sellerApology:
        return 'SELLER APPEAL';
      default:
        return 'NOTIFICATION';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
