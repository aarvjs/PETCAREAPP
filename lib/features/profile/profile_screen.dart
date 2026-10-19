import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/user_model.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/shop_service.dart';
import '../clinic/pet_registration_screen.dart';
import '../orders/orders_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _userModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = AuthService.instance.currentUser;
    if (user != null) {
      final model = await AuthService.instance.getUserProfile(user.uid);
      if (mounted) {
        setState(() {
          _userModel = model ?? UserModel(uid: user.uid, phoneNumber: user.phoneNumber ?? '');
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showEditProfileDialog() {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    final nameController = TextEditingController(text: _userModel?.name ?? '');
    final emailController = TextEditingController(text: _userModel?.email ?? '');
    final cityController = TextEditingController(text: _userModel?.city ?? '');
    final addressController = TextEditingController(text: _userModel?.address ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Update Profile Details',
                      style: TextStyle(
                        color: AppColors.mainText,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: AppColors.secondaryText),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Full Name
                const Text('Full Name', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: 'Enter your name'),
                ),
                const SizedBox(height: 14),

                // Email
                const Text('Email Address (Optional)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'Enter email address'),
                ),
                const SizedBox(height: 14),

                // City
                const Text('City (Optional)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(hintText: 'e.g. Swaroop Nagar, Kanpur'),
                ),
                const SizedBox(height: 14),

                // Address
                const Text('Delivery Address (Optional)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(hintText: 'House / Flat, Road, Landmark'),
                ),
                const SizedBox(height: 24),

                // Save Action
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      setState(() {
                        _isLoading = true;
                      });
                      await AuthService.instance.updateProfile(
                        uid: user.uid,
                        name: nameController.text.trim(),
                        email: emailController.text.trim(),
                        city: cityController.text.trim(),
                        address: addressController.text.trim(),
                        profileCompleted: true,
                        profileSkipped: false,
                      );
                      await _loadUserProfile();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sageGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onLogoutPressed() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to log out from this account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warmCoral,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Log Out', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.instance.signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.sageGreen),
        ),
      );
    }

    final displayName = (_userModel?.name != null && _userModel!.name!.trim().isNotEmpty)
        ? _userModel!.name!
        : 'Valued Pet Parent';

    final displayPhone = (_userModel?.phoneNumber != null && _userModel!.phoneNumber.isNotEmpty)
        ? _userModel!.phoneNumber
        : AuthService.instance.currentUser?.phoneNumber ?? 'Not registered';

    final displayLocation = (_userModel?.city != null && _userModel!.city!.trim().isNotEmpty)
        ? '${_userModel!.city!}${_userModel?.address != null && _userModel!.address!.trim().isNotEmpty ? ", ${_userModel!.address}" : ""}'
        : 'Tap to add address';

    final businessName = ShopService.instance.currentBusiness?.name ?? 'Healthy Paws Pet Clinic';

    final menuItems = [
      {
        'icon': Icons.receipt_long_rounded,
        'title': 'My Orders',
        'subtitle': 'Track purchases & clinic bookings',
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OrdersScreen()),
          );
        },
      },
      if (ShopService.instance.hasClinic)
        {
          'icon': Icons.pets_rounded,
          'title': 'My Pets & Registration',
          'subtitle': 'View registered pets & get registration numbers',
          'action': () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PetRegistrationScreen()),
            );
          },
        },
      {
        'icon': Icons.location_on_rounded,
        'title': 'Delivery Address',
        'subtitle': displayLocation,
        'action': _showEditProfileDialog,
      },
      {
        'icon': Icons.edit_note_rounded,
        'title': 'Edit Profile',
        'subtitle': 'Update name, contact and addresses',
        'action': _showEditProfileDialog,
      },
      {
        'icon': Icons.storefront_rounded,
        'title': 'Configured Shop',
        'subtitle': '$businessName (${AppConfig.shopId})',
        'action': () {},
      },
      {
        'icon': Icons.help_outline_rounded,
        'title': 'Help & Support',
        'subtitle': 'Contact veterinary support team',
        'action': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Support available via clinic reception.'),
              backgroundColor: AppColors.sageGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Profile',
                    style: TextStyle(
                      color: AppColors.mainText,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    onPressed: _showEditProfileDialog,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.sageGreen.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 18,
                        color: AppColors.sageGreen,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Profile Card Header (Dynamic data from Firestore)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mainText.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.softSage,
                        border: Border.all(color: AppColors.sageGreen, width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.pets_rounded,
                          color: AppColors.sageGreen,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  displayName,
                                  style: const TextStyle(
                                    color: AppColors.mainText,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (_userModel?.profileCompleted == true) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.verified_rounded, size: 16, color: AppColors.sageGreen),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            displayPhone,
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '📍 $displayLocation',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.sageGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Menu Options List
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mainText.withValues(alpha: 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: List.generate(menuItems.length, (index) {
                    final item = menuItems[index];
                    final isLast = index == menuItems.length - 1;

                    return Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.softSage,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              color: AppColors.sageGreen,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            item['title'] as String,
                            style: const TextStyle(
                              color: AppColors.mainText,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            item['subtitle'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.secondaryText,
                            size: 20,
                          ),
                          onTap: item['action'] as VoidCallback?,
                        ),
                        if (!isLast) const Divider(height: 1, indent: 64, endIndent: 16),
                      ],
                    );
                  }),
                ),
              ),

              const SizedBox(height: 20),

              // Logout Button
              GestureDetector(
                onTap: _onLogoutPressed,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.warmCoral.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: AppColors.warmCoral, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Logout Account',
                        style: TextStyle(
                          color: AppColors.warmCoral,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
