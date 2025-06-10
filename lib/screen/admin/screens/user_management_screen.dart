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
                    () => _updateUserStatus(context, users[index].id, true),
                onUnrestrict:
                    () => _updateUserStatus(context, users[index].id, false),
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
    bool isRestricted,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'isRestricted': isRestricted,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isRestricted
                  ? 'User has been restricted from uploading products'
                  : 'User restriction has been removed',
            ),
            backgroundColor: isRestricted ? Colors.red : Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating user status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onRestrict;
  final VoidCallback onUnrestrict;

  const _UserCard({
    required this.user,
    required this.onRestrict,
    required this.onUnrestrict,
  });

  @override
  Widget build(BuildContext context) {
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
                _StatusChip(
                  isRestricted: user.isRestricted,
                  isSeller: user.role == UserRole.seller,
                ),
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
            if (user.role == UserRole.seller)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (user.isRestricted)
                    ElevatedButton(
                      onPressed: onUnrestrict,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Remove Restriction'),
                    )
                  else
                    ElevatedButton(
                      onPressed: onRestrict,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Restrict'),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isRestricted;
  final bool isSeller;

  const _StatusChip({required this.isRestricted, required this.isSeller});

  @override
  Widget build(BuildContext context) {
    if (!isSeller) return const SizedBox.shrink();

    return Chip(
      label: Text(
        isRestricted ? 'Restricted' : 'Active',
        style: TextStyle(color: isRestricted ? Colors.white : Colors.black),
      ),
      backgroundColor: isRestricted ? Colors.red : Colors.green,
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
