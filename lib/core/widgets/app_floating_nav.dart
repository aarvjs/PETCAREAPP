import 'dart:ui';
import 'package:flutter/material.dart';
import '../cart/cart_service.dart';
import '../constants/app_colors.dart';

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
    final navItems = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.shopping_bag_rounded, 'label': 'Shop'},
      {'icon': Icons.medical_services_rounded, 'label': 'Clinic'},
      {'icon': Icons.shopping_cart_rounded, 'label': 'Cart'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return AnimatedBuilder(
      animation: CartService.instance,
      builder: (context, child) {
        final cartCount = CartService.instance.totalItemCount;

        return Container(
          margin: const EdgeInsets.only(left: 14, right: 14, bottom: 16),
          height: 74,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // Glass Capsule Background Surface
              ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.95),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPurple.withValues(alpha: 0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
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
                    children: List.generate(navItems.length, (index) {
                      final isSelected = selectedIndex == index;
                      final isClinic = index == 2;
                      final isCart = index == 3;
                      final item = navItems[index];

                      return Flexible(
                        child: GestureDetector(
                          onTap: () => onItemSelected(index),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Icon Container with Smooth Floating Transition
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOutCubic,
                                  transform: Matrix4.translationValues(
                                    0,
                                    isSelected ? -10 : (isClinic ? -4 : 0),
                                    0,
                                  ),
                                  width: isClinic ? 48 : (isSelected ? 42 : 36),
                                  height: isClinic ? 48 : (isSelected ? 42 : 36),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: (isSelected || isClinic)
                                        ? LinearGradient(
                                            colors: isSelected
                                                ? [
                                                    AppColors.primaryPurple,
                                                    AppColors.primaryContainer,
                                                  ]
                                                : [
                                                    AppColors.skyBlue,
                                                    AppColors.lightSky,
                                                  ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                    color: (isSelected || isClinic) ? null : Colors.transparent,
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primaryPurple.withValues(alpha: 0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    clipBehavior: Clip.none,
                                    children: [
                                      Icon(
                                        item['icon'] as IconData,
                                        size: isClinic ? 24 : (isSelected ? 22 : 20),
                                        color: isSelected
                                            ? AppColors.white
                                            : (isClinic
                                                ? AppColors.primaryPurple
                                                : AppColors.secondaryText),
                                      ),

                                      // Cart Count Badge
                                      if (isCart && cartCount > 0)
                                        Positioned(
                                          top: -2,
                                          right: -2,
                                          child: AnimatedScale(
                                            duration: const Duration(milliseconds: 200),
                                            scale: 1.0,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? AppColors.skyBlue
                                                    : AppColors.primaryPurple,
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
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? AppColors.primaryPurple
                                                      : AppColors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w900,
                                                ),
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
                                        ? AppColors.primaryPurple
                                        : AppColors.secondaryText,
                                    fontSize: 10,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  ),
                                  child: Text(
                                    item['label'] as String,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
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
