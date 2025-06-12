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
  final _verificationFormKey = GlobalKey<FormState>();
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

  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _checkSellerStatus();
  }

  Future<void> _checkSellerStatus() async {
    final authStore = context.read<AuthStore>();
    final currentUser = authStore.currentUser;

    if (currentUser == null) {
      setState(() {
        _isCheckingSeller = false;
      });
      return;
    }

    try {
      // Check if user is already a seller
      final sellerDoc =
          await FirebaseFirestore.instance
              .collection('sellers')
              .doc(currentUser.id)
              .get();

      if (sellerDoc.exists) {
        setState(() {
          _isSeller = true;
          _sellerData = sellerDoc.data();
          _isCheckingSeller = false;
        });
        return;
      }

      // Check for pending verification request
      final sellerStore = context.read<SellerStore>();
      final verificationRequest = await sellerStore.getVerificationStatus(
        currentUser.id,
      );

      if (verificationRequest != null) {
        setState(() {
          _applicationStatus = verificationRequest.status.name;
          _isCheckingSeller = false;
        });
      } else {
        setState(() {
          _isCheckingSeller = false;
        });
      }
    } catch (e) {
      debugPrint('Error checking seller status: $e');
      setState(() {
        _isCheckingSeller = false;
      });
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
              'Your application is being processed! We will review your application and notify you once it\'s approved.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
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
    // Validate shop information form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all shop information fields'),
        ),
      );
      return false;
    }

    // Validate verification form
    if (!_verificationFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all verification fields'),
        ),
      );
      return false;
    }

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
    return true;
  }

  void _nextStep() {
    if (_currentStep < 1) {
      // Validate current step before proceeding
      if (_currentStep == 0 && !_formKey.currentState!.validate()) {
        return;
      }

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
  Widget build(BuildContext context) {
    if (_isCheckingSeller) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Become a Seller'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_isSeller) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Seller Dashboard'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.store,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome, Seller!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You are already registered as a seller.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/seller-dashboard'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Go to Dashboard'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_applicationStatus != null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text('Application Status'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _applicationStatus == 'pending'
                    ? Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            strokeWidth: 6,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.orange.shade300,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.hourglass_top,
                          size: 40,
                          color: Colors.orange,
                        ),
                      ],
                    )
                    : Icon(
                      _applicationStatus == 'approved'
                          ? Icons.check_circle
                          : Icons.cancel,
                      size: 80,
                      color:
                          _applicationStatus == 'approved'
                              ? Colors.green
                              : Colors.red,
                    ),
                const SizedBox(height: 16),
                Text(
                  _applicationStatus == 'pending'
                      ? 'Application Being Processed'
                      : _applicationStatus == 'approved'
                      ? 'Application Approved'
                      : 'Application Rejected',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color:
                        _applicationStatus == 'pending'
                            ? Colors.orange
                            : _applicationStatus == 'approved'
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _applicationStatus == 'pending'
                      ? 'Your application is being processed by our admin team. We will notify you once it\'s reviewed and approved.'
                      : _applicationStatus == 'approved'
                      ? 'Congratulations! Your seller application has been approved.'
                      : 'Your seller application has been rejected. Please contact support for more information.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (_applicationStatus == 'approved')
                  ElevatedButton(
                    onPressed: () => context.go('/seller-dashboard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('Go to Dashboard'),
                  ),
                if (_applicationStatus == 'rejected')
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _applicationStatus = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('Apply Again'),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Seller'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                for (int i = 0; i < 2; i++) ...[
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color:
                            i <= _currentStep
                                ? Theme.of(context).primaryColor
                                : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (i < 1) const SizedBox(width: 8),
                ],
              ],
            ),
          ),

          // Step Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [_buildShopInformationStep(), _buildVerificationStep()],
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
                      onPressed: _previousStep,
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: Observer(
                    builder: (context) {
                      final sellerStore = context.read<SellerStore>();
                      return ElevatedButton(
                        onPressed:
                            sellerStore.isLoading
                                ? null
                                : _currentStep < 1
                                ? _nextStep
                                : _submitVerificationRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child:
                            sellerStore.isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : Text(_currentStep < 1 ? 'Next' : 'Submit'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopInformationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
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
              'Tell us about your shop',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Shop Name
            TextFormField(
              controller: _shopNameController,
              decoration: const InputDecoration(
                labelText: 'Shop Name',
                hintText: 'Enter your shop name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your shop name';
                }
                if (value.trim().length < 3) {
                  return 'Shop name must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Contact Number
            TextFormField(
              controller: _contactNumberController,
              decoration: const InputDecoration(
                labelText: 'Contact Number',
                hintText: 'Enter your contact number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your contact number';
                }
                if (value.trim().length < 10) {
                  return 'Please enter a valid contact number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Shop Location
            TextFormField(
              controller: _shopLocationController,
              decoration: const InputDecoration(
                labelText: 'Shop Location',
                hintText: 'Enter your shop location',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your shop location';
                }
                if (value.trim().length < 10) {
                  return 'Please provide a detailed location';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _verificationFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Identity Verification',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload your ID and take a verification photo',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // ID Type Selection
            DropdownButtonFormField<PhilippineIDType>(
              value: _selectedIdType,
              decoration: const InputDecoration(
                labelText: 'ID Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card),
              ),
              items:
                  PhilippineIDType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getIdTypeDisplayName(type)),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedIdType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // ID Number
            TextFormField(
              controller: _idNumberController,
              decoration: const InputDecoration(
                labelText: 'ID Number',
                hintText: 'Enter your ID number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your ID number';
                }
                return null;
              },
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
            const SizedBox(height: 16),

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
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool isUploaded,
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
          padding: const EdgeInsets.all(16),
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
                          subtitle,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (imagePath != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(imagePath),
                    height: 200,
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
      case PhilippineIDType.farmerID:
        return 'Farmer ID';
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
}
