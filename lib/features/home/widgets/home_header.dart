import 'package:flutter/material.dart';
import '../../../core/cart/cart_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/shop_service.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onOpenDrawer;
  final VoidCallback onCartTap;
  final VoidCallback onProfileTap;
  final VoidCallback? onNotificationTap;

  const HomeHeader({
    super.key,
    required this.onOpenDrawer,
    required this.onCartTap,
    required this.onProfileTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final business = ShopService.instance.currentBusiness;
    final shopName = business?.name ?? 'Healthy Paws Pet Clinic';
    final locationText = business?.city != null && business!.city!.isNotEmpty
        ? '${business.city!}${business.state != null && business.state!.isNotEmpty ? ", ${business.state}" : ""}'
        : 'Pet Clinic & Store';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        children: [
          // Left: Menu Icon
          InkWell(
            onTap: onOpenDrawer,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: const Icon(
                Icons.menu_rounded,
                color: AppColors.mainText,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Center: Shop Name & Location (Flexible to prevent any overflow)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        shopName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.mainText,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: AppColors.accentCoral,
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        locationText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Right: Cart Button with live Badge
          ListenableBuilder(
            listenable: CartService.instance,
            builder: (context, _) {
              final count = CartService.instance.totalItemCount;

              return InkWell(
                onTap: onCartTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.mainText,
                        size: 20,
                      ),
                      if (count > 0)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: AppColors.accentCoral,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$count',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),

          // Profile Avatar Button
          InkWell(
            onTap: onProfileTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
