import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kiko_app_mobile_app/core/models/seller_verification_request_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kiko_app_mobile_app/core/stores/notification_store.dart';
import 'package:kiko_app_mobile_app/core/models/notification_model.dart';

class SellerRequestsScreen extends StatelessWidget {
  const SellerRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.go('/admin'),
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text('Seller Verification Requests'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending', icon: Icon(Icons.pending_actions)),
              Tab(text: 'Approved', icon: Icon(Icons.check_circle)),
              Tab(text: 'Rejected', icon: Icon(Icons.cancel)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRequestsList(VerificationStatus.pending),
            _buildRequestsList(VerificationStatus.approved),
            _buildRequestsList(VerificationStatus.rejected),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList(VerificationStatus status) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('seller_verification_requests')
              .where('status', isEqualTo: status.name)
              .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data?.docs ?? [];

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getStatusIcon(status),
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No ${status.name} requests',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = SellerVerificationRequest.fromSnapshot(
              requests[index],
            );
            return _SellerVerificationCard(
              request: request,
              onApprove:
                  status == VerificationStatus.pending
                      ? () => _updateRequestStatus(
                        context,
                        requests[index].id,
                        VerificationStatus.approved,
                      )
                      : null,
              onReject:
                  status == VerificationStatus.pending
                      ? () => _showRejectDialog(context, requests[index].id)
                      : null,
            );
          },
        );
      },
    );
  }

  IconData _getStatusIcon(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return Icons.pending_actions;
      case VerificationStatus.approved:
        return Icons.check_circle;
      case VerificationStatus.rejected:
        return Icons.cancel;
    }
  }

  void _showRejectDialog(BuildContext context, String requestId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reject Verification Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please provide a reason for rejection:'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  hintText: 'Enter rejection reason...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateRequestStatus(
                  context,
                  requestId,
                  VerificationStatus.rejected,
                  rejectionReason: reasonController.text.trim(),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Reject',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateRequestStatus(
    BuildContext context,
    String requestId,
    VerificationStatus status, {
    String? rejectionReason,
  }) async {
    try {
      final requestRef = FirebaseFirestore.instance
          .collection('seller_verification_requests')
          .doc(requestId);

      final request = await requestRef.get();
      final requestData = request.data() as Map<String, dynamic>;

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Update request status
        Map<String, dynamic> updateData = {
          'status': status.name,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (rejectionReason != null && rejectionReason.isNotEmpty) {
          updateData['rejectionReason'] = rejectionReason;
        }

        if (status == VerificationStatus.approved) {
          updateData['approvedAt'] = FieldValue.serverTimestamp();
          updateData['approvedBy'] =
              'current_admin_id'; // TODO: Replace with actual admin ID
        }

        transaction.update(requestRef, updateData);

        if (status == VerificationStatus.approved) {
          // Create seller profile
          final sellerRef = FirebaseFirestore.instance
              .collection('sellers')
              .doc(requestData['userId']);

          transaction.set(sellerRef, {
            'userId': requestData['userId'],
            'shopName': requestData['shopName'],
            'contactNumber': requestData['contactNumber'],
            'shopLocation': requestData['shopLocation'],
            'idVerificationUrl': requestData['idImageUrl'],
            'faceVerificationUrl': requestData['faceVerificationUrl'],
            'createdAt': FieldValue.serverTimestamp(),
            'idType': requestData['idType'],
            'idNumber': requestData['idNumber'],
            'verificationStatus': 'verified',
            'biometricVerified': requestData['biometricVerified'] ?? false,
            'totalOrders': 0,
            'totalProducts': 0,
            'profilePhotoUrl': requestData['faceVerificationUrl'],
            'status': 'active',
          });

          // Update user role
          final userRef = FirebaseFirestore.instance
              .collection('users')
              .doc(requestData['userId']);

          transaction.update(userRef, {
            'role': 'seller',
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Send notification to user
          final notificationStore = NotificationStore();
          await notificationStore.createNotification(
            userId: requestData['userId'],
            title: 'Seller Application Approved',
            message:
                'Congratulations! Your seller application has been approved. You can now start selling on our platform.',
            type: NotificationType.sellerApproval,
          );
        } else {
          // Send notification to user
          final notificationStore = NotificationStore();
          await notificationStore.createNotification(
            userId: requestData['userId'],
            title: 'Seller Application Rejected',
            message:
                'We regret to inform you that your seller application has been rejected. Please contact support for more information.',
            type: NotificationType.sellerApproval,
          );
        }
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification request ${status.name} successfully'),
            backgroundColor: _getStatusColor(status),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return Colors.orange;
      case VerificationStatus.approved:
        return Colors.green;
      case VerificationStatus.rejected:
        return Colors.red;
    }
  }
}

class _SellerVerificationCard extends StatelessWidget {
  final SellerVerificationRequest request;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _SellerVerificationCard({
    required this.request,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(request.status),
          child: Icon(_getStatusIcon(request.status), color: Colors.white),
        ),
        title: Text(
          request.shopName,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Owner: ${request.userName}'),
            Text('Applied: ${_formatDate(request.createdAt)}'),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Business Information'),
                const SizedBox(height: 8),
                _InfoRow(label: 'Shop Name', value: request.shopName),
                _InfoRow(label: 'Contact Number', value: request.contactNumber),
                _InfoRow(label: 'Shop Location', value: request.shopLocation),
                const SizedBox(height: 16),
                _buildSectionTitle('Personal Information'),
                const SizedBox(height: 8),
                _InfoRow(label: 'Name', value: request.userName),
                _InfoRow(label: 'Email', value: request.userEmail),
                _InfoRow(label: 'Phone', value: request.userPhone),
                const SizedBox(height: 16),
                _buildSectionTitle('ID Verification'),
                const SizedBox(height: 8),
                _InfoRow(label: 'ID Type', value: request.idTypeDisplayName),
                _InfoRow(label: 'ID Number', value: request.idNumber),
                const SizedBox(height: 8),
                _buildImageSection('ID Document', request.idImageUrl),
                const SizedBox(height: 16),
                _buildSectionTitle('Face Verification'),
                const SizedBox(height: 8),
                _InfoRow(
                  label: 'Biometric Verified',
                  value: request.biometricVerified ? 'Yes' : 'No',
                  valueColor:
                      request.biometricVerified ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 8),
                _buildImageSection('Face Photo', request.faceVerificationUrl),
                if (request.rejectionReason != null) ...[
                  const SizedBox(height: 16),
                  _buildSectionTitle('Rejection Reason'),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      request.rejectionReason!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
                if (onApprove != null || onReject != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onReject != null) ...[
                        TextButton.icon(
                          onPressed: onReject,
                          icon: const Icon(Icons.cancel),
                          label: const Text('Reject'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (onApprove != null)
                        ElevatedButton.icon(
                          onPressed: onApprove,
                          icon: const Icon(Icons.check),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildImageSection(String title, String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) =>
                      const Center(child: CircularProgressIndicator()),
              errorWidget:
                  (context, url, error) =>
                      const Center(child: Icon(Icons.error, color: Colors.red)),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  IconData _getStatusIcon(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return Icons.pending_actions;
      case VerificationStatus.approved:
        return Icons.check_circle;
      case VerificationStatus.rejected:
        return Icons.cancel;
    }
  }

  Color _getStatusColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return Colors.orange;
      case VerificationStatus.approved:
        return Colors.green;
      case VerificationStatus.rejected:
        return Colors.red;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontWeight:
                    valueColor != null ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
