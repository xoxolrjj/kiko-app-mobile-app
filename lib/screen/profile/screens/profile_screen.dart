import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kiko_app_mobile_app/screen/widgets/kiko_images.dart';
import 'package:provider/provider.dart';
import 'package:kiko_app_mobile_app/core/stores/auth_store.dart';
import 'package:kiko_app_mobile_app/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? sellerData;
  bool isLoadingSeller = false;

  @override
  void initState() {
    super.initState();
    _loadSellerData();
  }

  Future<void> _loadSellerData() async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    if (authStore.currentUser?.role == UserRole.seller) {
      setState(() => isLoadingSeller = true);
      try {
        final doc =
            await FirebaseFirestore.instance
                .collection('sellers')
                .doc(authStore.currentUser!.id)
                .get();

        if (doc.exists && mounted) {
          setState(() => sellerData = doc.data());
        }
      } catch (e) {
        debugPrint('Error loading seller data: $e');
      } finally {
        if (mounted) setState(() => isLoadingSeller = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authStore = Provider.of<AuthStore>(context);

    if (authStore.currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view your profile')),
      );
    }

    final user = authStore.currentUser!;
    final isSeller = user.role == UserRole.seller;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isSeller ? 'Seller Profile' : 'Profile',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Profile Header
              _buildProfileHeader(user, isSeller),

              if (isSeller) ...[
                // Seller-specific features
                //   _buildSellerStats(),
                const SizedBox(height: 24),
                _buildSellerActions(),
                const SizedBox(height: 24),
              ],
              SizedBox(height: 12),

              // Common profile options
              _buildProfileOptions(user, isSeller),

              const SizedBox(height: 32),

              // Logout button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await authStore.signOut();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user, bool isSeller) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isSeller
                    ? [Colors.green.shade400, Colors.green.shade600]
                    : [Colors.blue.shade400, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Profile Photo with Upload Button
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child:
                      sellerData?['profilePhotoUrl'] != null
                          ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: sellerData!['profilePhotoUrl'],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) =>
                                      const CircularProgressIndicator(),
                              errorWidget:
                                  (context, url, error) => const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                            ),
                          )
                          : KikoImage(
                            imagePath: user.photoUrl ?? '',
                            width: 100,
                            height: 100,
                            isCircular: true,
                          ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 20),
                      color: isSeller ? Colors.green : Colors.blue,
                      onPressed: () => _pickAndUploadImage(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),

            // Role Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isSeller ? 'Verified Seller' : 'User',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            if (isSeller && sellerData != null) ...[
              const SizedBox(height: 16),

              // Location
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      sellerData!['shopLocation'] ?? 'Location not set',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Contact Number
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.phone, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    sellerData!['contactNumber'] ?? 'No contact number',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) return;

      setState(() => isLoadingSeller = true);

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child(
            '${Provider.of<AuthStore>(context, listen: false).currentUser!.id}.jpg',
          );

      await storageRef.putFile(File(image.path));
      final downloadUrl = await storageRef.getDownloadURL();

      // Update Firestore
      final authStore = Provider.of<AuthStore>(context, listen: false);
      if (authStore.currentUser?.role == UserRole.seller) {
        await FirebaseFirestore.instance
            .collection('sellers')
            .doc(authStore.currentUser!.id)
            .update({'photoUrl': downloadUrl});
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(authStore.currentUser!.id)
            .update({'photoUrl': downloadUrl});
      }

      // Reload seller data
      await _loadSellerData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated successfully')),
        );
      }
    } catch (e) {
      debugPrint('Error uploading profile photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile photo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoadingSeller = false);
      }
    }
  }

  // Widget _buildSellerStats() {
  //   if (isLoadingSeller) {
  //     return const Center(child: CircularProgressIndicator());
  //   }

  //   return Row(
  //     children: [
  //       Expanded(
  //         child: _StatCard(
  //           title: 'Total Orders',
  //           value: (sellerData?['totalOrders'] ?? 0).toString(),
  //           icon: Icons.shopping_bag,
  //           color: Colors.green,
  //         ),
  //       ),
  //       const SizedBox(width: 12),
  //       Expanded(
  //         child: _StatCard(
  //           title: 'Products',
  //           value: (sellerData?['totalProducts'] ?? 0).toString(),
  //           icon: Icons.inventory_2,
  //           color: Colors.blue,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildSellerActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seller Management',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // My Products
        _ActionCard(
          title: 'My Products',
          subtitle: 'Manage your product listings',
          icon: Icons.inventory_2,
          color: Colors.blue,
          onTap: () => context.go('/seller/products'),
        ),
        const SizedBox(height: 12),

        // Order Requests
        _ActionCard(
          title: 'Order Requests',
          subtitle: 'View and manage incoming orders',
          icon: Icons.receipt_long,
          color: Colors.orange,
          onTap: () => context.go('/seller/orders'),
        ),
        //  const SizedBox(height: 12),

        // Messages
        // _ActionCard(
        //   title: 'Messages',
        //   subtitle: 'View and respond to customer messages',
        //   icon: Icons.message,
        //   color: Colors.blue,
        //   onTap: () => context.go('/seller/messages'),
        // ),
      ],
    );
  }

  Widget _buildProfileOptions(UserModel user, bool isSeller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isSeller
            ? const SizedBox()
            : Text(
              'Account Settings',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
        const SizedBox(height: 16),
        isSeller
            ? const SizedBox()
            : _ActionCard(
              title: 'My Orders',
              subtitle: 'View your order history and status',
              icon: Icons.shopping_bag,
              color: Colors.green,
              onTap: () => context.go('/my-orders'),
            ),
        //  const SizedBox(height: 12),

        // _ActionCard(
        //   title: 'Edit Profile',
        //   subtitle: 'Update your personal information',
        //   icon: Icons.edit,
        //   color: Colors.purple,
        //   onTap: () {
        //     // TODO: Navigate to edit profile
        //   },
        // ),
        const SizedBox(height: 12),

        // if (!isSeller) ...[
        //   const SizedBox(height: 12),
        // Container(child:Column(children:[
        //   Text('List of Users ')

        // ]).)
        // ],
      ],
    );
  }
}

 
class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
