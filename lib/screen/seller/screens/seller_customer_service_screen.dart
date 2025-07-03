import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:kiko_app_mobile_app/core/models/apology_message_model.dart';
import 'package:kiko_app_mobile_app/core/stores/apology_store.dart';
import 'package:kiko_app_mobile_app/core/stores/auth_store.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class SellerCustomerServiceScreen extends StatefulWidget {
  const SellerCustomerServiceScreen({super.key});

  @override
  State<SellerCustomerServiceScreen> createState() =>
      _SellerCustomerServiceScreenState();
}

class _SellerCustomerServiceScreenState
    extends State<SellerCustomerServiceScreen> {
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ApologyStore _apologyStore = ApologyStore();
  late String? _sellerId;

  @override
  void initState() {
    super.initState();
    final authStore = Provider.of<AuthStore>(context, listen: false);
    _sellerId = authStore.currentUser?.id;
    if (_sellerId != null) {
      _apologyStore.loadSellerApologyMessages(_sellerId!);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authStore = Provider.of<AuthStore>(context);
    final currentUser = authStore.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Customer Service'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/profile'),
          ),
        ),
        body: const Center(
          child: Text('Please log in to access customer service'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Service'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Status Card
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            'Account Restricted',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your seller account has been restricted. You can send an apology message to the admin team to request a review of your account status.',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Send Apology Message Form
              Text(
                'Send Apology Message',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _messageController,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Your Message',
                        hintText:
                            'Explain your situation and apologize for any issues...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your message';
                        }
                        if (value.trim().length < 10) {
                          return 'Message must be at least 10 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Observer(
                      builder:
                          (context) => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _apologyStore.isLoading
                                      ? null
                                      : _sendApologyMessage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child:
                                  _apologyStore.isLoading
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : const Text('Send Apology Message'),
                            ),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Previous Messages
              Text(
                'Previous Messages',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<ApologyMessageModel>>(
                stream: _apologyStore.getSellerApologyMessagesStream(
                  _sellerId!,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading messages: ${snapshot.error}',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data ?? [];

                  if (messages.isEmpty) {
                    return const Center(
                      child: Text(
                        'No previous messages',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _ApologyMessageCard(message: message);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendApologyMessage() async {
    if (!_formKey.currentState!.validate()) return;

    final authStore = Provider.of<AuthStore>(context, listen: false);
    final currentUser = authStore.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to send a message')),
      );
      return;
    }

    await _apologyStore.sendApologyMessage(
      sellerId: currentUser.id,
      sellerName: currentUser.name,
      sellerEmail: currentUser.email,
      message: _messageController.text.trim(),
    );

    if (_apologyStore.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_apologyStore.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Apology message sent successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

class _ApologyMessageCard extends StatelessWidget {
  final ApologyMessageModel message;

  const _ApologyMessageCard({required this.message});

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
              children: [
                Icon(
                  _getStatusIcon(message.status),
                  color: _getStatusColor(message.status),
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(message.status),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(message.status),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(message.createdAt),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Your Message:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(message.message),
            if (message.adminResponse != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Response:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message.adminResponse!,
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                    if (message.reviewedAt != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Reviewed on: ${_formatDate(message.reviewedAt!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(ApologyStatus status) {
    switch (status) {
      case ApologyStatus.pending:
        return Icons.pending;
      case ApologyStatus.reviewed:
        return Icons.visibility;
      case ApologyStatus.resolved:
        return Icons.check_circle;
    }
  }

  Color _getStatusColor(ApologyStatus status) {
    switch (status) {
      case ApologyStatus.pending:
        return Colors.orange;
      case ApologyStatus.reviewed:
        return Colors.blue;
      case ApologyStatus.resolved:
        return Colors.green;
    }
  }

  String _getStatusText(ApologyStatus status) {
    switch (status) {
      case ApologyStatus.pending:
        return 'Pending Review';
      case ApologyStatus.reviewed:
        return 'Reviewed';
      case ApologyStatus.resolved:
        return 'Resolved';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
