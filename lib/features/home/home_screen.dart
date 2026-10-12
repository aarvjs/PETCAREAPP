import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/business_model.dart';
import '../../core/services/shop_service.dart';
import '../clinic/widgets/clinic_home_view.dart';
import 'widgets/categories_section.dart';
import 'widgets/healthcare_section.dart';
import 'widgets/hero_slider.dart';
import 'widgets/home_header.dart';
import 'widgets/promo_banner.dart';
import 'widgets/top_products_section.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onOpenDrawer;
  final Function(int)? onNavigateToTab;

  const HomeScreen({
    super.key,
    required this.onOpenDrawer,
    this.onNavigateToTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'Dog';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: ShopService.instance,
          builder: (context, _) {
            final exp = ShopService.instance.experience;

            // 1. Dedicated Clinic-Only Mode
            if (exp == AppExperience.clinicOnly) {
              return ClinicHomeView(
                onOpenDrawer: widget.onOpenDrawer,
                onNavigateToTab: widget.onNavigateToTab,
              );
            }

            // 2. Clinic Enabled But Not Yet Published
            if (exp == AppExperience.clinicPendingSetup) {
              return _buildClinicPendingSetupView();
            }

            // 3. E-Commerce Only or Combined Experience
            final isCombined = exp == AppExperience.combined;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header
                  HomeHeader(
                    onOpenDrawer: widget.onOpenDrawer,
                    onCartTap: () {
                      final cartTabIndex = isCombined ? 3 : 2;
                      widget.onNavigateToTab?.call(cartTabIndex);
                    },
                    onProfileTap: () {
                      final profileTabIndex = isCombined ? 4 : 3;
                      widget.onNavigateToTab?.call(profileTabIndex);
                    },
                  ),

                  const SizedBox(height: 12),

                  // 2. Hero Image Slider
                  HeroSlider(
                    onBannerTap: (index) {
                      if (index == 2 && isCombined) {
                        widget.onNavigateToTab?.call(2); // Clinic tab
                      } else {
                        widget.onNavigateToTab?.call(1); // Shop tab
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // 3. Categories Horizontal Section
                  CategoriesSection(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    onViewAllTap: () {
                      widget.onNavigateToTab?.call(1); // Shop tab
                    },
                  ),

                  const SizedBox(height: 24),

                  // 4. Top Products Horizontal Carousel
                  TopProductsSection(
                    selectedCategory: _selectedCategory,
                    onViewAllTap: () {
                      widget.onNavigateToTab?.call(1); // Shop tab
                    },
                  ),

                  const SizedBox(height: 24),

                  // 5. Healthcare Services Section (rendered only if Combined mode)
                  if (isCombined) ...[
                    HealthcareSection(
                      onViewAllTap: () {
                        widget.onNavigateToTab?.call(2); // Clinic tab
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 6. Promotional Banner
                  PromoBanner(
                    title: isCombined
                        ? 'Love Them. Care For Them.'
                        : 'Nutritious & Delicious Pet Care',
                    subtitle: isCombined
                        ? 'Professional healthcare & clinic visits for every stage of life.'
                        : 'Discover healthy food, tasty treats, and playful toys.',
                    buttonLabel: isCombined ? 'Explore Clinic' : 'Browse Shop',
                    onExploreClinicTap: () {
                      if (isCombined) {
                        widget.onNavigateToTab?.call(2); // Clinic tab
                      } else {
                        widget.onNavigateToTab?.call(1); // Shop tab
                      }
                    },
                  ),

                  const SizedBox(height: 100), // Spacing for floating nav bar
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildClinicPendingSetupView() {
    final biz = ShopService.instance.currentBusiness;
    final clinicName = biz?.name ?? 'Healthy Paws Clinic';
    final phone = biz?.phone ?? '+91 98765 43210';
    final timings = biz?.clinicTimings ?? 'Mon - Sat: 09:00 AM - 08:00 PM';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medical_services_rounded,
                size: 52,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              clinicName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.mainText,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Online Clinic Services Coming Soon',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Our clinic doctors and services are currently being configured by the administrative team. For immediate inquiries, please reach out directly.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(phone, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Operating Hours: $timings',
                    style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
