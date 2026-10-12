import 'dart:ui';
import 'package:flutter/material.dart';
import '../cart/cart_service.dart';
import '../constants/app_colors.dart';
import '../models/business_model.dart';
import '../services/shop_service.dart';

class NavTabItem {
  final int index;
  final IconData icon;
  final String label;
  final bool isCart;

  const NavTabItem({
    required this.index,
    required this.icon,
    required this.label,
    this.isCart = false,
  });
}

class AppFloatingNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const AppFloatingNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([CartService.instance, ShopService.instance]),
      builder: (context, child) {
        final exp = ShopService.instance.experience;
        final cartCount = CartService.instance.totalItemCount;

        List<NavTabItem> navItems;

        if (exp == AppExperience.clinicOnly) {
          // Dedicated Clinic Only Experience
          navItems = const [
            NavTabItem(index: 0, icon: Icons.local_hospital_rounded, label: 'Clinic'),
            NavTabItem(index: 1, icon: Icons.medical_services_rounded, label: 'Services'),
            NavTabItem(index: 2, icon: Icons.calendar_today_rounded, label: 'Bookings'),
            NavTabItem(index: 3, icon: Icons.person_rounded, label: 'Profile'),
          ];
        } else if (exp == AppExperience.ecommerceOnly) {
          // Dedicated E-Commerce Only Experience
          navItems = [
            const NavTabItem(index: 0, icon: Icons.home_rounded, label: 'Home'),
            const NavTabItem(index: 1, icon: Icons.shopping_bag_rounded, label: 'Shop'),
            const NavTabItem(
              index: 2,
              icon: Icons.shopping_cart_rounded,
              label: 'Cart',
              isCart: true,
            ),
            const NavTabItem(
              index: 3,
              icon: Icons.person_rounded,
              label: 'Profile',
            ),
          ];
        } else {
          // Combined Mode (Both E-Commerce and Clinic active & published)
          navItems = [
            const NavTabItem(index: 0, icon: Icons.home_rounded, label: 'Home'),
            const NavTabItem(index: 1, icon: Icons.shopping_bag_rounded, label: 'Shop'),
            const NavTabItem(index: 2, icon: Icons.medical_services_rounded, label: 'Clinic'),
            const NavTabItem(
              index: 3,
              icon: Icons.shopping_cart_rounded,
              label: 'Cart',
              isCart: true,
            ),
            const NavTabItem(
              index: 4,
              icon: Icons.person_rounded,
              label: 'Profile',
            ),
          ];
        }

        return Container(
          margin: const EdgeInsets.only(left: 14, right: 14, bottom: 16),
          height: 74,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // Capsule Background Surface
              ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.mainText.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Navigation Items Row
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: navItems.map((tab) {
                      final isSelected = selectedIndex == tab.index;

                      return Flexible(
                        child: GestureDetector(
                          onTap: () => onItemSelected(tab.index),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Icon Container with Smooth Floating Transition
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOutCubic,
                                  transform: Matrix4.translationValues(
                                    0,
                                    isSelected ? -8 : 0,
                                    0,
                                  ),
                                  width: isSelected ? 42 : 36,
                                  height: isSelected ? 42 : 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? AppColors.sageGreen : Colors.transparent,
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.sageGreen.withValues(alpha: 0.35),
                                              blurRadius: 10,
                                              offset: const Offset(0, 3),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    clipBehavior: Clip.none,
                                    children: [
                                      Icon(
                                        tab.icon,
                                        size: isSelected ? 22 : 20,
                                        color: isSelected
                                            ? AppColors.white
                                            : AppColors.secondaryText,
                                      ),

                                      // Cart Count Badge
                                      if (tab.isCart && cartCount > 0)
                                        Positioned(
                                          top: -2,
                                          right: -2,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.warmCoral
                                                  : AppColors.warmCoral,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: AppColors.white,
                                                width: 1.2,
                                              ),
                                            ),
                                            constraints: const BoxConstraints(
                                              minWidth: 16,
                                              minHeight: 16,
                                            ),
                                            child: Text(
                                              '$cartCount',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: AppColors.white,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 2),

                                // Clearly Visible Label
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.sageGreen
                                        : AppColors.secondaryText,
                                    fontSize: 10,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  ),
                                  child: Text(
                                    tab.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
