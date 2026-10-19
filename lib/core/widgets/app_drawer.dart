import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../config/app_config.dart';
import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../models/business_model.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/shop_service.dart';
import '../../features/clinic/my_pets_screen.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const AppDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final profile = AuthService.instance.currentUserProfile;
    final businessName = ShopService.instance.currentBusiness?.name ?? 'Healthy Paws';

    final displayName = (profile?.name != null && profile!.name!.trim().isNotEmpty)
        ? profile.name!
        : ((user?.displayName != null && user!.displayName!.trim().isNotEmpty)
            ? user.displayName!
            : 'Valued Pet Parent');

    final displayPhone = (profile?.phoneNumber != null && profile!.phoneNumber.trim().isNotEmpty)
        ? profile.phoneNumber
        : (user?.phoneNumber ?? 'Online Customer');

    final exp = ShopService.instance.experience;
    final List<Map<String, dynamic>> menuItems;

    if (exp == AppExperience.clinicOnly) {
      menuItems = [
        {'icon': Icons.local_hospital_rounded, 'title': 'Clinic Home', 'index': 0},
        {'icon': Icons.medical_services_rounded, 'title': 'Clinical Services', 'index': 1},
        {'icon': Icons.calendar_today_rounded, 'title': 'My Appointments', 'index': 2},
        {'icon': Icons.person_rounded, 'title': 'My Profile', 'index': 3},
      ];
    } else if (exp == AppExperience.ecommerceOnly) {
      menuItems = [
        {'icon': Icons.home_rounded, 'title': 'Home Store', 'index': 0},
        {'icon': Icons.shopping_bag_rounded, 'title': 'Shop Catalog', 'index': 1},
        {'icon': Icons.shopping_cart_rounded, 'title': 'My Cart', 'index': 2},
        {'icon': Icons.person_rounded, 'title': 'My Profile', 'index': 3},
      ];
    } else {
      menuItems = [
        {'icon': Icons.home_rounded, 'title': 'Home', 'index': 0},
        {'icon': Icons.shopping_bag_rounded, 'title': 'Shop Catalog', 'index': 1},
        {'icon': Icons.medical_services_rounded, 'title': 'Veterinary Clinic', 'index': 2},
        {'icon': Icons.shopping_cart_rounded, 'title': 'My Cart', 'index': 3},
        {'icon': Icons.person_rounded, 'title': 'My Profile', 'index': 4},
      ];
    }

    return Drawer(
      width: 290,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        children: [
          // White container with rounded right corners
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mainText.withValues(alpha: 0.08),
                  blurRadius: 32,
                  offset: const Offset(8, 0),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Subtle background SVG paw watermarks
                Positioned(
                  top: -20,
                  right: -20,
                  child: Opacity(
                    opacity: 0.04,
                    child: SvgPicture.asset(
                      AppAssets.logoPaw,
                      width: 160,
                    ),
                  ),
                ),

                // Main Content
                SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // Profile Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.softSage,
                                border: Border.all(
                                  color: AppColors.sageGreen,
                                  width: 1.5,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.pets_rounded,
                                  color: AppColors.sageGreen,
                                  size: 26,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.mainText,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    displayPhone,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.secondaryText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Business & Shop ID Pill
                      Container(
                        margin: const EdgeInsets.only(top: 14, left: 20, right: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.parchment,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.storefront_rounded, size: 16, color: AppColors.sageGreen),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '$businessName • ${AppConfig.shopId}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.mainText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      const Divider(color: AppColors.surfaceContainerLow, height: 1),
                      const SizedBox(height: 8),

                      // "My Pets" Dedicated Entry in Drawer
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MyPetsScreen(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                              decoration: BoxDecoration(
                                color: AppColors.softSage.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.sageGreen.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: AppColors.sageGreen,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.pets_rounded,
                                        size: 18,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'My Pets',
                                          style: TextStyle(
                                            color: AppColors.mainText,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Text(
                                          'View registered pet IDs',
                                          style: TextStyle(
                                            color: AppColors.secondaryText,
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 20,
                                    color: AppColors.sageGreen,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Menu Items
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          itemCount: menuItems.length,
                          itemBuilder: (context, index) {
                            final item = menuItems[index];
                            final itemNavIndex = item['index'] as int;
                            final isSelected = selectedIndex == itemNavIndex;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                    onItemSelected(itemNavIndex);
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.sageGreen.withValues(alpha: 0.1)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          item['icon'] as IconData,
                                          size: 22,
                                          color: isSelected
                                              ? AppColors.sageGreen
                                              : AppColors.secondaryText,
                                        ),
                                        const SizedBox(width: 14),
                                        Text(
                                          item['title'] as String,
                                          style: TextStyle(
                                            color: isSelected
                                                ? AppColors.sageGreen
                                                : AppColors.mainText,
                                            fontSize: 14,
                                            fontWeight: isSelected
                                                ? FontWeight.w800
                                                : FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const Divider(color: AppColors.surfaceContainerLow, height: 1),

                      // Logout Item Bottom
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              Navigator.pop(context);
                              await AuthService.instance.signOut();
                              if (!context.mounted) return;
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.login,
                                (route) => false,
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.warmCoral.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.logout_rounded,
                                    size: 20,
                                    color: AppColors.warmCoral,
                                  ),
                                  SizedBox(width: 14),
                                  Text(
                                    'Logout',
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
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
