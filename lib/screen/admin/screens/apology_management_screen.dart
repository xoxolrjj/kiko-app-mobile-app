import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:kiko_app_mobile_app/core/models/apology_message_model.dart';
import 'package:kiko_app_mobile_app/core/stores/apology_store.dart';
import 'package:kiko_app_mobile_app/core/stores/auth_store.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class ApologyManagementScreen extends StatefulWidget {
  const ApologyManagementScreen({super.key});

  @override
  State<ApologyManagementScreen> createState() =>
      _ApologyManagementScreenState();
}

class _ApologyManagementScreenState extends State<ApologyManagementScreen> {
  final ApologyStore _apologyStore = ApologyStore();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _apologyStore.loadApologyMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Apology Messages'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _apologyStore.loadApologyMessages(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedFilter == 'all',
                  onSelected: () => setState(() => _selectedFilter = 'all'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pending',
                  isSelected: _selectedFilter == 'pending',
                  onSelected: () => setState(() => _selectedFilter = 'pending'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Reviewed',
                  isSelected: _selectedFilter == 'reviewed',
                  onSelected:
                      () => setState(() => _selectedFilter = 'reviewed'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Resolved',
                  isSelected: _selectedFilter == 'resolved',
                  onSelected:
                      () => setState(() => _selectedFilter = 'resolved'),
                ),
              ],
            ),
          ),
          // Messages list
          Expanded(
            child: StreamBuilder<List<ApologyMessageModel>>(
              stream: _apologyStore.getApologyMessagesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _apologyStore.loadApologyMessages(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allMessages = snapshot.data ?? [];
                final filteredMessages = _filterMessages(allMessages);

                if (filteredMessages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter == 'all'
                              ? 'No apology messages found'
                              : 'No ${_selectedFilter} messages found',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredMessages.length,
                  itemBuilder: (context, index) {
                    final message = filteredMessages[index];
                    return _ApologyMessageCard(
                      message: message,
                      onRespond: () => _showResponseDialog(message),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<ApologyMessageModel> _filterMessages(
    List<ApologyMessageModel> messages,
  ) {
    if (_selectedFilter == 'all') return messages;

    return messages.where((message) {
      switch (_selectedFilter) {
        case 'pending':
          return message.status == ApologyStatus.pending;
        case 'reviewed':
          return message.status == ApologyStatus.reviewed;
        case 'resolved':
          return message.status == ApologyStatus.resolved;
        default:
          return true;
      }
    }).toList();
  }

  void _showResponseDialog(ApologyMessageModel message) {
    showDialog(
      context: context,
      builder:
          (context) =>
              _ResponseDialog(message: message, onRespond: _respondToApology),
    );
  }

  Future<void> _respondToApology(
    ApologyMessageModel message,
    String response,
    ApologyStatus status,
  ) async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    final adminId = authStore.currentAdmin?.id ?? authStore.currentUser?.id;

    if (adminId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin authentication required')),
      );
      return;
    }

    await _apologyStore.respondToApology(
      apologyId: message.id,
      adminResponse: response,
      reviewedBy: adminId,
      status: status,
    );

    if (_apologyStore.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_apologyStore.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Response sent successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue,
    );
  }
}

class _ApologyMessageCard extends StatelessWidget {
  final ApologyMessageModel message;
  final VoidCallback onRespond;

  const _ApologyMessageCard({required this.message, required this.onRespond});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(Icons.person, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.sellerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        message.sellerEmail,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _StatusChip(status: message.status),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(message.createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Message content
            Text(
              'Apology Message:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                message.message,
                style: const TextStyle(fontSize: 14),
              ),
            ),

            // Admin response if exists
            if (message.adminResponse != null) ...[
              const SizedBox(height: 16),
              Text(
                'Admin Response:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  message.adminResponse!,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              if (message.reviewedAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Reviewed on: ${_formatDate(message.reviewedAt!)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ],

            // Action buttons
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (message.status == ApologyStatus.pending)
                  ElevatedButton.icon(
                    onPressed: onRespond,
                    icon: const Icon(Icons.reply),
                    label: const Text('Respond'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  )
                else if (message.status == ApologyStatus.reviewed)
                  ElevatedButton.icon(
                    onPressed: onRespond,
                    icon: const Icon(Icons.edit),
                    label: const Text('Update Response'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusChip extends StatelessWidget {
  final ApologyStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusText(status),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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
        return 'PENDING';
      case ApologyStatus.reviewed:
        return 'REVIEWED';
      case ApologyStatus.resolved:
        return 'RESOLVED';
    }
  }
}

class _ResponseDialog extends StatefulWidget {
  final ApologyMessageModel message;
  final Function(ApologyMessageModel, String, ApologyStatus) onRespond;

  const _ResponseDialog({required this.message, required this.onRespond});

  @override
  State<_ResponseDialog> createState() => _ResponseDialogState();
}

class _ResponseDialogState extends State<_ResponseDialog> {
  final _responseController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  ApologyStatus _selectedStatus = ApologyStatus.reviewed;

  @override
  void initState() {
    super.initState();
    if (widget.message.adminResponse != null) {
      _responseController.text = widget.message.adminResponse!;
      _selectedStatus = widget.message.status;
    }
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Respond to ${widget.message.sellerName}'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Original message
              Text(
                'Original Message:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.message.message,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),

              // Response field
              TextFormField(
                controller: _responseController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Your Response',
                  hintText: 'Enter your response to the seller...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a response';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Status selection
              Text(
                'Status:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ApologyStatus>(
                value: _selectedStatus,
                items:
                    ApologyStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(_getStatusText(status)),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _sendResponse,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Send Response'),
        ),
      ],
    );
  }

  void _sendResponse() {
    if (_formKey.currentState!.validate()) {
      widget.onRespond(
        widget.message,
        _responseController.text.trim(),
        _selectedStatus,
      );
      Navigator.pop(context);
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
}
