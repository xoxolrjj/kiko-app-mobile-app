import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kiko_app_mobile_app/core/models/user_model.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/admin'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('User Management'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data?.docs ?? [];

          if (users.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = UserModel.fromSnapshot(users[index]);
              return _UserCard(
                user: user,
                onRestrict:
                    () => _updateUserStatus(
                      context,
                      users[index].id,
                      'restricted',
                    ),
                onUnrestrict:
                    () => _updateUserStatus(context, users[index].id, 'active'),
                onBan:
                    () => _updateUserStatus(context, users[index].id, 'banned'),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _updateUserStatus(
    BuildContext context,
    String userId,
    String status,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('User $status successfully')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating user: $e')));
      }
    }
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onRestrict;
  final VoidCallback onUnrestrict;
  final VoidCallback onBan;

  const _UserCard({
    required this.user,
    required this.onRestrict,
    required this.onUnrestrict,
    required this.onBan,
  });

  @override
  Widget build(BuildContext context) {
    // Get user status from the user data (add default status if not present)
    final String userStatus =
        'active'; // Default status since it's not in the user model yet

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(user.name, style: Theme.of(context).textTheme.titleLarge),
                _StatusChip(status: userStatus),
              ],
            ),
            const SizedBox(height: 16),
            _InfoRow(label: 'Email', value: user.email),
            _InfoRow(label: 'Role', value: user.role.name.toUpperCase()),
            _InfoRow(label: 'Phone', value: user.phoneNumber ?? 'Not provided'),
            _InfoRow(
              label: 'Location',
              value: user.location.isNotEmpty ? user.location : 'Not provided',
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (userStatus == 'active')
                  TextButton(
                    onPressed: onRestrict,
                    child: const Text('Restrict'),
                  )
                else if (userStatus == 'restricted')
                  TextButton(
                    onPressed: onUnrestrict,
                    child: const Text('Unrestrict'),
                  ),
                if (userStatus != 'banned') ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onBan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Ban'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'active':
        color = Colors.green;
        break;
      case 'restricted':
        color = Colors.orange;
        break;
      case 'banned':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
