import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kiko_app_mobile_app/core/models/user_model.dart';

class AdminCommunicationScreen extends StatefulWidget {
  const AdminCommunicationScreen({super.key});

  @override
  State<AdminCommunicationScreen> createState() =>
      _AdminCommunicationScreenState();
}

class _AdminCommunicationScreenState extends State<AdminCommunicationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  String _selectedRecipientType = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/admin'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Admin Communication'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Send Message'),
            Tab(text: 'Sellers'),
            Tab(text: 'Users'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSendMessageTab(),
          _buildSellersTab(),
          _buildUsersTab(),
        ],
      ),
    );
  }

  Widget _buildSendMessageTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Send Message',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedRecipientType,
            decoration: const InputDecoration(
              labelText: 'Recipient Type',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Users')),
              DropdownMenuItem(value: 'sellers', child: Text('All Sellers')),
              DropdownMenuItem(
                value: 'users',
                child: Text('Regular Users Only'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedRecipientType = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: _messageController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Type your message here...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _sendMessage,
              child: const Text('Send Message'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: UserRole.seller.name)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final sellers = snapshot.data?.docs ?? [];

        if (sellers.isEmpty) {
          return const Center(child: Text('No sellers found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sellers.length,
          itemBuilder: (context, index) {
            final seller = UserModel.fromSnapshot(sellers[index]);
            return _UserListCard(
              user: seller,
              onMessage: () => _openDirectMessage(seller),
            );
          },
        );
      },
    );
  }

  Widget _buildUsersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: UserRole.user.name)
              .snapshots(),
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
            return _UserListCard(
              user: user,
              onMessage: () => _openDirectMessage(user),
            );
          },
        );
      },
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a message')));
      return;
    }

    try {
      // Create a broadcast message that will appear as notification to users
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': 'Message from Admin',
        'message': _messageController.text.trim(),
        'type': 'admin',
        'recipientType': _selectedRecipientType,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      _messageController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sending message: $e')));
      }
    }
  }

  void _openDirectMessage(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => _DirectMessageDialog(user: user),
    );
  }
}

class _UserListCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onMessage;

  const _UserListCard({required this.user, required this.onMessage});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
              user.photoUrl != null && user.photoUrl!.isNotEmpty
                  ? NetworkImage(user.photoUrl!)
                  : null,
          child:
              user.photoUrl == null || user.photoUrl!.isEmpty
                  ? Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  )
                  : null,
        ),
        title: Text(user.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            Text(
              user.role.name.toUpperCase(),
              style: TextStyle(
                color:
                    user.role == UserRole.seller ? Colors.green : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.message),
          onPressed: onMessage,
        ),
      ),
    );
  }
}

class _DirectMessageDialog extends StatefulWidget {
  final UserModel user;

  const _DirectMessageDialog({required this.user});

  @override
  State<_DirectMessageDialog> createState() => _DirectMessageDialogState();
}

class _DirectMessageDialogState extends State<_DirectMessageDialog> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Message ${widget.user.name}'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _sendDirectMessage,
          child: const Text('Send'),
        ),
      ],
    );
  }

  Future<void> _sendDirectMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      // Create a direct message notification for the specific user
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': 'Direct Message from Admin',
        'message': _messageController.text.trim(),
        'type': 'admin',
        'recipientId': widget.user.id,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sending message: $e')));
      }
    }
  }
}
