import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import '../routes/app_routes.dart';

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
    final menuItems = [
      {'icon': Icons.home_rounded, 'title': 'Home', 'index': 0},
      {'icon': Icons.shopping_bag_rounded, 'title': 'Shop', 'index': 1},
      {'icon': Icons.grid_view_rounded, 'title': 'Categories', 'index': 1},
      {'icon': Icons.pets_rounded, 'title': 'My Pets', 'index': 4},
      {'icon': Icons.medical_services_rounded, 'title': 'Clinic', 'index': 2},
      {'icon': Icons.calendar_month_rounded, 'title': 'Appointments', 'index': 2},
      {'icon': Icons.receipt_long_rounded, 'title': 'Orders', 'index': 3},
      {'icon': Icons.favorite_rounded, 'title': 'Favorites', 'index': 1},
      {'icon': Icons.notifications_rounded, 'title': 'Notifications', 'index': 0},
      {'icon': Icons.settings_rounded, 'title': 'Settings', 'index': 4},
      {'icon': Icons.help_outline_rounded, 'title': 'Help & Support', 'index': 4},
    ];

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
                  color: AppColors.primaryPurple.withValues(alpha: 0.12),
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
                    opacity: 0.08,
                    child: SvgPicture.asset(
                      AppAssets.logoPaw,
                      width: 160,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: -30,
                  child: Opacity(
                    opacity: 0.06,
                    child: SvgPicture.asset(
                      AppAssets.logoPaw,
                      width: 180,
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
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.skyBlue,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryPurple.withValues(alpha: 0.15),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  AppAssets.userAvatar,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Sarah Jenkins',
                                    style: TextStyle(
                                      color: AppColors.mainText,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'sarah.jenkins@example.com',
                                    style: TextStyle(
                                      color: AppColors.secondaryText,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Divider(color: AppColors.surfaceContainer, height: 1),
                      const SizedBox(height: 12),

                      // Menu Items
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          itemCount: menuItems.length,
                          itemBuilder: (context, index) {
                            final item = menuItems[index];
                            final itemNavIndex = item['index'] as int;
                            final isSelected = selectedIndex == itemNavIndex && index < 5;

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
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 11),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.lightSky
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                      border: isSelected
                                          ? Border.all(
                                              color: AppColors.skyBlue.withValues(alpha: 0.5),
                                              width: 1,
                                            )
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          item['icon'] as IconData,
                                          size: 20,
                                          color: isSelected
                                              ? AppColors.primaryPurple
                                              : AppColors.secondaryText,
                                        ),
                                        const SizedBox(width: 14),
                                        Text(
                                          item['title'] as String,
                                          style: TextStyle(
                                            color: isSelected
                                                ? AppColors.primaryPurple
                                                : AppColors.mainText,
                                            fontSize: 14,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
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

                      const Divider(color: AppColors.surfaceContainer, height: 1),

                      // Logout Item Bottom
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushReplacementNamed(context, AppRoutes.login);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.errorRed.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.logout_rounded,
                                    size: 20,
                                    color: AppColors.errorRed,
                                  ),
                                  SizedBox(width: 14),
                                  Text(
                                    'Logout',
                                    style: TextStyle(
                                      color: AppColors.errorRed,
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
