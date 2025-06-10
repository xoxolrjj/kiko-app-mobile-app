import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kiko_app_mobile_app/core/models/seller_verification_request_model.dart';
import 'package:kiko_app_mobile_app/core/models/user_model.dart';
import 'package:kiko_app_mobile_app/core/stores/auth_store.dart';
import 'package:kiko_app_mobile_app/core/stores/seller_store.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class BecomeASeller extends StatefulWidget {
  const BecomeASeller({super.key});

  @override
  State<BecomeASeller> createState() => _BecomeASellerState();
}

class _BecomeASellerState extends State<BecomeASeller> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isCheckingSeller = true;
  bool _isSeller = false;
  Map<String, dynamic>? _sellerData;
  String? _applicationStatus;

  // Shop Information
  final _shopNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _shopLocationController = TextEditingController();

  // ID Verification
  PhilippineIDType _selectedIdType = PhilippineIDType.psaBirthCertificate;
  final _idNumberController = TextEditingController();
  String? _idImagePath;

  // Face Verification
  String? _faceImagePath;
  bool _biometricVerified = false;

  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _checkSellerStatus();
    // Using temporary biometric initialization (always returns true)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SellerStore>().initializeBiometrics();
    });
  }

  Future<void> _checkSellerStatus() async {
    setState(() => _isCheckingSeller = true);
    try {
      final authStore = context.read<AuthStore>();
      final userId = authStore.currentUser?.id;

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('User not logged in')));
        }
        return;
      }

      // First check if user is already a seller
      final sellerDoc =
          await FirebaseFirestore.instance
              .collection('sellers')
              .doc(userId)
              .get();

      if (sellerDoc.exists) {
        setState(() {
          _isSeller = true;
          _sellerData = sellerDoc.data();
        });
        return;
      }

      // Then check for existing verification requests
      final verificationQuery =
          await FirebaseFirestore.instance
              .collection('seller_verification_requests')
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .limit(1)
              .get();

      if (verificationQuery.docs.isNotEmpty) {
        final request = SellerVerificationRequest.fromSnapshot(
          verificationQuery.docs.first,
        );
        setState(() {
          _applicationStatus = request.status.name;
        });

        if (mounted) {
          String message;
          switch (request.status) {
            case VerificationStatus.pending:
              message =
                  'Your seller application is pending review. Please wait for admin approval.';
              break;
            case VerificationStatus.rejected:
              message =
                  'Your seller application was rejected. Reason: ${request.rejectionReason ?? "No reason provided"}';
              break;
            case VerificationStatus.approved:
              message = 'Your seller application has been approved.';
              break;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: _getStatusColor(request.status),
            ),
          );
          context.go('/home');
        }
      }
    } catch (e) {
      debugPrint('Error checking seller status: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isCheckingSeller = false);
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

  Future<void> _pickImage(bool isIdImage) async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1920,
      maxHeight: 1080,
    );
    if (image != null) {
      setState(() {
        if (isIdImage) {
          _idImagePath = image.path;
        } else {
          _faceImagePath = image.path;
        }
      });
    }
  }

  Future<void> _takeFacePhoto() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1920,
      maxHeight: 1080,
    );
    if (image != null) {
      setState(() {
        _faceImagePath = image.path;
      });
    }
  }

  // Temporary method for when biometric verification is disabled
  Future<void> _performBiometricVerification() async {
    setState(() {
      _biometricVerified = true;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biometric verification skipped for now'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  Future<void> _submitVerificationRequest() async {
    if (!_validateAllSteps()) return;

    final sellerStore = context.read<SellerStore>();
    final authStore = context.read<AuthStore>();
    final currentUser = authStore.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not logged in')));
      return;
    }

    await sellerStore.submitSellerVerificationRequest(
      businessName:
          _shopNameController.text.trim(), // Use shop name as business name
      businessType: 'General', // Default business type
      shopName: _shopNameController.text.trim(),
      contactNumber: _contactNumberController.text.trim(),
      shopLocation: _shopLocationController.text.trim(),
      businessAddress:
          _shopLocationController.text
              .trim(), // Use shop location as business address
      idType: _selectedIdType,
      idNumber: _idNumberController.text.trim(),
      idImagePath: _idImagePath!,
      faceImagePath: _faceImagePath!,
      currentUser: currentUser,
    );

    if (sellerStore.errorMessage == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Verification request submitted successfully! Please wait for admin approval.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/home');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(sellerStore.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _validateAllSteps() {
    if (!_formKey.currentState!.validate()) return false;
    if (_idImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your ID document')),
      );
      return false;
    }
    if (_faceImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please take a face verification photo')),
      );
      return false;
    }
    if (!_biometricVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete biometric verification')),
      );
      return false;
    }
    return true;
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _contactNumberController.dispose();
    _shopLocationController.dispose();
    _idNumberController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingSeller) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isSeller) {
      return _buildSellerWelcomeScreen();
    }

    if (_applicationStatus != null) {
      return _buildApplicationStatusScreen();
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        automaticallyImplyLeading: true,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_sharp, size: 18),
              onPressed: () => context.go('/home'),
            ),
            const SizedBox(width: 8),
            Text(
              'Become a Seller',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                for (int i = 0; i < 3; i++)
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color:
                            i <= _currentStep
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Step Indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStepIndicator(0, 'Business Info'),
                _buildStepIndicator(1, 'ID Verification'),
                _buildStepIndicator(2, 'Face Verification'),
              ],
            ),
          ),

          // Form Content
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildBusinessInfoStep(),
                  _buildIdVerificationStep(),
                  _buildFaceVerificationStep(),
                ],
              ),
            ),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        setState(() => _currentStep--);
                      },
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _currentStep < 2
                            ? () {
                              if (_formKey.currentState?.validate() ?? false) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                                setState(() => _currentStep++);
                              }
                            }
                            : _submitVerificationRequest,
                    child: Text(_currentStep < 2 ? 'Next' : 'Submit'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerWelcomeScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.green.shade50, Colors.white],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.verified,
                  size: 60,
                  color: Colors.green.shade600,
                ),
              ),

              const SizedBox(height: 32),

              // Welcome Message
              Text(
                'Welcome, Seller!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Congratulations Message
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Congratulations!',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'You are now a verified seller on KikoApp. Start managing your store and adding products to reach more customers!',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Shop Information
              if (_sellerData != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.store, color: Colors.green.shade600),
                          const SizedBox(width: 8),
                          Text(
                            _sellerData!['shopName'] ?? 'Your Shop',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (_sellerData!['shopLocation'] != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.green.shade600,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_sellerData!['shopLocation'])),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Action Buttons
              Column(
                children: [
                  // Manage Products Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/seller/products'),
                      icon: const Icon(Icons.inventory_2, size: 24),
                      label: const Text(
                        'Manage Products',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // View Orders Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/seller/orders'),
                      icon: const Icon(Icons.receipt_long, size: 24),
                      label: const Text(
                        'View Orders',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green.shade600,
                        side: BorderSide(
                          color: Colors.green.shade600,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Go to Profile Button
                  TextButton.icon(
                    onPressed: () => context.go('/profile'),
                    icon: const Icon(Icons.person_outline),
                    label: const Text('View My Profile'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
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

  Widget _buildApplicationStatusScreen() {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_sharp, size: 18),
              onPressed: () => context.go('/home'),
            ),
            const SizedBox(width: 8),
            Text(
              'Application Status',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _applicationStatus == 'approved'
                    ? Icons.check_circle
                    : _applicationStatus == 'rejected'
                    ? Icons.cancel
                    : Icons.pending_actions,
                size: 80,
                color:
                    _applicationStatus == 'approved'
                        ? Colors.green
                        : _applicationStatus == 'rejected'
                        ? Colors.red
                        : Colors.orange,
              ),
              const SizedBox(height: 24),
              Text(
                _applicationStatus == 'approved'
                    ? 'Application Approved!'
                    : _applicationStatus == 'rejected'
                    ? 'Application Rejected'
                    : 'Application Pending',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _applicationStatus == 'approved'
                    ? 'Congratulations! Your seller account has been approved. You can now start selling your products.'
                    : _applicationStatus == 'rejected'
                    ? 'We\'re sorry, but your application has been rejected. Please contact support for more information.'
                    : 'Your application is being reviewed. We\'ll notify you once it\'s been processed.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shop Information',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide your shop details',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _shopNameController,
            label: 'Shop Name',
            hint: 'Enter your shop display name',
            prefixIcon: Icons.store,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _contactNumberController,
            label: 'Contact Number',
            hint: 'Enter your business contact number',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _shopLocationController,
            label: 'Shop Location',
            hint: 'Enter your shop location',
            prefixIcon: Icons.location_on,
          ),
        ],
      ),
    );
  }

  Widget _buildIdVerificationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ID Verification',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide a valid Philippine government-issued ID',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // ID Type Dropdown
          DropdownButtonFormField<PhilippineIDType>(
            value: _selectedIdType,
            decoration: InputDecoration(
              labelText: 'ID Type',
              prefixIcon: const Icon(Icons.credit_card),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items:
                PhilippineIDType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getIdTypeDisplayName(type)),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedIdType = value!;
              });
            },
            validator: (value) {
              if (value == null) return 'Please select an ID type';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // ID Number
          _buildTextField(
            controller: _idNumberController,
            label: 'ID Number',
            hint: 'Enter your ${_getIdTypeDisplayName(_selectedIdType)} number',
            prefixIcon: Icons.numbers,
          ),
          const SizedBox(height: 24),

          // ID Image Upload
          _buildUploadCard(
            title: 'Upload ID Document',
            subtitle:
                'Clear photo of your ${_getIdTypeDisplayName(_selectedIdType)}',
            icon: Icons.upload_file,
            onTap: () => _pickImage(true),
            isUploaded: _idImagePath != null,
            imagePath: _idImagePath,
          ),
        ],
      ),
    );
  }

  Widget _buildFaceVerificationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Face Verification',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take a clear photo and complete biometric verification',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Face Photo Upload
          _buildUploadCard(
            title: 'Take Face Photo',
            subtitle: 'Take a clear photo or upload from gallery',
            icon: Icons.face,
            onTap: _takeFacePhoto,
            isUploaded: _faceImagePath != null,
            imagePath: _faceImagePath,
          ),
          const SizedBox(height: 16),

          // Alternative upload from gallery
          _buildUploadCard(
            title: 'Upload from Gallery',
            subtitle: 'Select a clear photo from your gallery',
            icon: Icons.photo_library,
            onTap: () => _pickImage(false),
            isUploaded: false,
          ),
          const SizedBox(height: 24),

          // Biometric Verification
          Observer(
            builder: (context) {
              final sellerStore = context.read<SellerStore>();

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color:
                        _biometricVerified
                            ? Colors.green
                            : Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (_biometricVerified
                                      ? Colors.green
                                      : Theme.of(context).primaryColor)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _biometricVerified
                                  ? Icons.verified
                                  : Icons.fingerprint,
                              color:
                                  _biometricVerified
                                      ? Colors.green
                                      : Theme.of(context).primaryColor,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Biometric Verification',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _biometricVerified
                                      ? 'Verification completed successfully'
                                      : 'Use fingerprint or face ID to verify your identity',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color:
                                        _biometricVerified
                                            ? Colors.green
                                            : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (!_biometricVerified) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            // Commented out biometric check for now
                            // onPressed:
                            //     sellerStore.biometricCheckAvailable
                            //         ? _performBiometricVerification
                            //         : null,
                            onPressed: _performBiometricVerification,
                            icon: const Icon(Icons.fingerprint),
                            label: const Text('Skip Verification (for now)'),
                            // label: Text(
                            //   sellerStore.biometricCheckAvailable
                            //       ? 'Verify Identity'
                            //       : 'Biometric not available',
                            // ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getIdTypeDisplayName(PhilippineIDType type) {
    switch (type) {
      case PhilippineIDType.psaBirthCertificate:
        return 'PSA Birth Certificate';
      case PhilippineIDType.passport:
        return 'Philippine Passport';
      case PhilippineIDType.driversLicense:
        return "Driver's License";
      case PhilippineIDType.votersId:
        return "Voter's ID";
      case PhilippineIDType.sssId:
        return 'SSS ID';
      case PhilippineIDType.tinId:
        return 'TIN ID';
      case PhilippineIDType.philHealthId:
        return 'PhilHealth ID';
      case PhilippineIDType.prcId:
        return 'PRC ID';
      case PhilippineIDType.seniorCitizenId:
        return 'Senior Citizen ID';
      case PhilippineIDType.pwdId:
        return 'PWD ID';
      case PhilippineIDType.postalId:
        return 'Postal ID';
      case PhilippineIDType.barangayId:
        return 'Barangay ID';
      case PhilippineIDType.nationalID:
        return 'National ID';
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isUploaded = false,
    String? imagePath,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              isUploaded
                  ? Colors.green
                  : Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isUploaded
                              ? Colors.green
                              : Theme.of(context).primaryColor)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isUploaded ? Icons.check_circle : icon,
                      color:
                          isUploaded
                              ? Colors.green
                              : Theme.of(context).primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isUploaded ? 'File uploaded successfully' : subtitle,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: isUploaded ? Colors.green : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isUploaded ? Icons.edit : Icons.arrow_forward_ios,
                    color:
                        isUploaded
                            ? Colors.green
                            : Theme.of(context).primaryColor,
                    size: 16,
                  ),
                ],
              ),
              if (imagePath != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(imagePath),
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    return Text(
      label,
      style: TextStyle(
        color:
            _currentStep >= step ? Theme.of(context).primaryColor : Colors.grey,
        fontSize: 12,
      ),
    );
  }
}
