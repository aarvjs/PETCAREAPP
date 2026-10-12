import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/shop_service.dart';

class ShopUnavailableScreen extends StatelessWidget {
  final ShopResolutionState state;
  final VoidCallback? onRetry;

  const ShopUnavailableScreen({
    super.key,
    required this.state,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final title = _getTitle();
    final message = _getMessage();
    final icon = _getIcon();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Branded Icon Circle
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.mainText.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 44,
                        color: state == ShopResolutionState.inactive
                            ? AppColors.errorRed
                            : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Brand name badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppConfig.appName.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.mainText,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  ElevatedButton.icon(
                    onPressed: () {
                      if (onRetry != null) {
                        onRetry!();
                      } else {
                        ShopService.instance.initialize();
                      }
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Retry Connection'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),

                  // Debug mode helper button: allows developer testing with default shop
                  if (kDebugMode && state != ShopResolutionState.inactive) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        AppConfig.setRuntimeShopId(AppConfig.defaultShopId);
                        ShopService.instance.initialize();
                      },
                      icon: const Icon(Icons.developer_mode_rounded, size: 18),
                      label: const Text('Test with Default Shop (SHOP-D9E8)'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    switch (state) {
      case ShopResolutionState.missingShopId:
        return 'Shop ID Not Configured';
      case ShopResolutionState.inactive:
        return 'Business Currently Inactive';
      case ShopResolutionState.notFound:
        return 'Business Not Found';
      default:
        return 'Store Currently Unavailable';
    }
  }

  String _getMessage() {
    final currentShop = AppConfig.shopId;
    switch (state) {
      case ShopResolutionState.missingShopId:
        return 'No Shop ID was provided at compile-time. Each app build must receive its unique Shop ID via:\n\nflutter run --dart-define=SHOP_ID=YOUR_SHOP_ID';
      case ShopResolutionState.inactive:
        return 'The business associated with Shop ID "$currentShop" is currently inactive or suspended. Please contact clinic administration.';
      case ShopResolutionState.notFound:
        return 'No registered business was found in the database for Shop ID "$currentShop". Please verify your business registration.';
      default:
        return 'We are unable to connect to the business catalog at this time. Please check your internet connection.';
    }
  }

  IconData _getIcon() {
    switch (state) {
      case ShopResolutionState.missingShopId:
        return Icons.storefront_outlined;
      case ShopResolutionState.inactive:
        return Icons.block_flipped;
      case ShopResolutionState.notFound:
        return Icons.search_off_rounded;
      default:
        return Icons.cloud_off_rounded;
    }
  }
}
