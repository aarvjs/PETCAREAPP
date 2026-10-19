import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/pet_model.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/pet_service.dart';
import '../../core/services/shop_service.dart';
import 'pet_detail_screen.dart';

class PetRegistrationScreen extends StatefulWidget {
  const PetRegistrationScreen({super.key});

  @override
  State<PetRegistrationScreen> createState() => _PetRegistrationScreenState();
}

class _PetRegistrationScreenState extends State<PetRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the 11 fields
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerAddressController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _petNameController = TextEditingController();
  final TextEditingController _coatColourController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String _selectedSpecies = 'Dog';
  String _selectedGender = 'Male';
  DateTime? _selectedDob;

  File? _selectedPhoto;
  final ImagePicker _picker = ImagePicker();

  String _previewRegNumber = 'Loading...';
  bool _isLoadingPreview = true;
  bool _isSubmitting = false;
  double _uploadProgress = 0.0;
  String? _uploadStatusText;

  final List<String> _speciesList = ['Dog', 'Cat', 'Bird', 'Rabbit', 'Other'];
  final List<String> _genderList = ['Male', 'Female', 'Neutered Male', 'Spayed Female'];

  @override
  void initState() {
    super.initState();
    _prefillUserData();
    _loadRegistrationNumberPreview();
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _ownerAddressController.dispose();
    _contactNumberController.dispose();
    _petNameController.dispose();
    _coatColourController.dispose();
    _breedController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _prefillUserData() {
    final user = AuthService.instance.currentUser;
    final profile = AuthService.instance.currentUserProfile;

    if (profile?.name != null && profile!.name!.trim().isNotEmpty) {
      _ownerNameController.text = profile.name!.trim();
    } else if (user?.displayName != null && user!.displayName!.trim().isNotEmpty) {
      _ownerNameController.text = user.displayName!.trim();
    }

    if (profile?.phoneNumber != null && profile!.phoneNumber.trim().isNotEmpty) {
      _contactNumberController.text = profile.phoneNumber.trim();
    } else if (user?.phoneNumber != null && user!.phoneNumber!.trim().isNotEmpty) {
      _contactNumberController.text = user.phoneNumber!.trim();
    }

    final addressParts = <String>[];
    if (profile?.address != null && profile!.address!.trim().isNotEmpty) {
      addressParts.add(profile.address!.trim());
    }
    if (profile?.city != null && profile!.city!.trim().isNotEmpty) {
      addressParts.add(profile.city!.trim());
    }
    if (addressParts.isNotEmpty) {
      _ownerAddressController.text = addressParts.join(', ');
    }
  }

  Future<void> _loadRegistrationNumberPreview() async {
    final biz = ShopService.instance.currentBusiness;
    if (biz != null) {
      final preview = await PetService.instance.previewNextRegistrationNumber(biz.id);
      if (mounted) {
        setState(() {
          _previewRegNumber = preview;
          _isLoadingPreview = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _previewRegNumber = '${PetService.defaultPrefix}01';
          _isLoadingPreview = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _selectedPhoto = File(picked.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not access photo gallery: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  void _removePhoto() {
    setState(() {
      _selectedPhoto = null;
    });
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(now.year - 1, now.month, now.day),
      firstDate: DateTime(now.year - 25),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.mainText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDob = pickedDate;
        _dobController.text = '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _submitRegistration() async {
    // 1. Authenticate user
    final user = AuthService.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in with your phone number before registering a pet.'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pushNamed(AppRoutes.login);
      return;
    }

    // 2. Validate form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required registration details.'),
          backgroundColor: AppColors.accentCoral,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_dobController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your pet\'s Date of Birth.'),
          backgroundColor: AppColors.accentCoral,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _uploadProgress = 0.0;
      _uploadStatusText = _selectedPhoto != null ? 'Uploading pet photo...' : 'Registering pet...';
    });

    try {
      final pet = await PetService.instance.registerPet(
        ownerId: user.uid,
        ownerName: _ownerNameController.text.trim(),
        ownerAddress: _ownerAddressController.text.trim(),
        contactNumber: _contactNumberController.text.trim(),
        name: _petNameController.text.trim(),
        species: _selectedSpecies,
        gender: _selectedGender,
        coatColour: _coatColourController.text.trim(),
        breed: _breedController.text.trim(),
        dob: _dobController.text.trim(),
        photoFile: _selectedPhoto,
        onUploadProgress: (progress) {
          if (mounted) {
            setState(() {
              _uploadProgress = progress;
              _uploadStatusText = 'Uploading photo: ${(progress * 100).toInt()}%';
            });
          }
        },
      );

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });

      _showSuccessDialog(pet);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Registration Failed', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.errorRed)),
          content: Text(
            'We encountered an issue saving the pet record:\n${e.toString().replaceAll('Exception:', '').trim()}\n\nPlease retry or check your network connection.',
            style: const TextStyle(fontSize: 14, color: AppColors.secondaryText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
          ],
        ),
      );
    }
  }

  void _showSuccessDialog(PetModel pet) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pet Registered!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.mainText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${pet.name} has been officially registered at ${ShopService.instance.currentBusiness?.name ?? "Healthy Paws Pet Clinic"}.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Text(
                      'OFFICIAL REGISTRATION NUMBER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondaryText,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pet.registrationNumber,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogCtx);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PetDetailScreen(pet: pet),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('View Pet Profile', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Back to Clinic',
                  style: TextStyle(color: AppColors.secondaryText, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final biz = ShopService.instance.currentBusiness;
    final clinicName = biz?.name ?? 'Healthy Paws Pet Clinic';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Register Your Pet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.mainText,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.mainText),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card with Registration Number Preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.pets_rounded, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clinicName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.mainText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Text(
                                'Reg. No: ',
                                style: TextStyle(fontSize: 12, color: AppColors.secondaryText, fontWeight: FontWeight.w600),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainer,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  _isLoadingPreview ? 'Allocating...' : _previewRegNumber,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 1: Pet Photo (Optional Upload)
              _buildSectionHeader('Pet Photo (Optional)', 'Upload a clear picture of your pet'),
              const SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _selectedPhoto != null ? AppColors.primary : AppColors.border,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.mainText.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _selectedPhoto != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: Image.file(
                                  _selectedPhoto!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: _removePhoto,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.edit, size: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 22),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Add Photo',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Section 2: Pet Details
              _buildSectionHeader('Pet Details', 'Basic identification and physical description'),
              const SizedBox(height: 12),

              // Pet Name
              _buildTextField(
                controller: _petNameController,
                label: 'Pet Name *',
                hint: 'e.g. Bruno, Bella, Charlie',
                icon: Icons.pets_rounded,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Pet name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Species Selector
              const Text(
                'Species *',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.mainText),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _speciesList.map((species) {
                  final isSelected = _selectedSpecies == species;
                  return ChoiceChip(
                    label: Text(species),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.white,
                    side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.white : AppColors.mainText,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedSpecies = species);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Gender Selector
              const Text(
                'Gender *',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.mainText),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _genderList.map((gender) {
                  final isSelected = _selectedGender == gender;
                  return ChoiceChip(
                    label: Text(gender),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.white,
                    side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.white : AppColors.mainText,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedGender = gender);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Breed & Coat Colour in 2 columns
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _breedController,
                      label: 'Breed *',
                      hint: 'e.g. Labrador, Indie',
                      icon: Icons.category_rounded,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Breed required';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _coatColourController,
                      label: 'Coat Colour *',
                      hint: 'e.g. Golden, White',
                      icon: Icons.palette_outlined,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Colour required';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Date of Birth
              GestureDetector(
                onTap: _selectDateOfBirth,
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: _dobController,
                    label: 'Date of Birth *',
                    hint: 'YYYY-MM-DD (Tap to pick date)',
                    icon: Icons.calendar_today_rounded,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Date of birth is required';
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Section 3: Owner Details
              _buildSectionHeader('Owner / Guardian Details', 'Contact and address records for medical appointments'),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _ownerNameController,
                label: 'Owner Full Name *',
                hint: 'e.g. Rahul Sharma',
                icon: Icons.person_outline,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Owner name is required';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              _buildTextField(
                controller: _contactNumberController,
                label: 'Contact Number *',
                hint: 'e.g. 9876543210',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Contact number is required';
                  final clean = val.replaceAll(RegExp(r'\D'), '');
                  if (clean.length < 10) return 'Enter a valid 10-digit number';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              _buildTextField(
                controller: _ownerAddressController,
                label: 'Owner Address *',
                hint: 'House/Flat No, Area, City',
                icon: Icons.location_on_outlined,
                maxLines: 2,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Owner address is required';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              if (_isSubmitting) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: _uploadProgress > 0 ? _uploadProgress : null,
                        backgroundColor: AppColors.primaryContainer,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _uploadStatusText ?? 'Processing...',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _submitRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Complete Pet Registration',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.3),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.mainText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.mainText,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: AppColors.mainText, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.mutedText),
            prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.errorRed),
            ),
          ),
        ),
      ],
    );
  }
}
