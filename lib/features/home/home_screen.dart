import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header
              HomeHeader(
                onOpenDrawer: widget.onOpenDrawer,
                onNotificationTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No new notifications'),
                      backgroundColor: AppColors.primaryPurple,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                onProfileTap: () {
                  widget.onNavigateToTab?.call(4); // Profile tab
                },
              ),

              const SizedBox(height: 12),

              // 2. Hero Image Slider
              HeroSlider(
                onBannerTap: (index) {
                  if (index == 2) {
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

              // 5. Healthcare Services Section
              HealthcareSection(
                onViewAllTap: () {
                  widget.onNavigateToTab?.call(2); // Clinic tab
                },
              ),

              const SizedBox(height: 24),

              // 6. Bottom Promotional Banner
              PromoBanner(
                onExploreClinicTap: () {
                  widget.onNavigateToTab?.call(2); // Clinic tab
                },
              ),

              const SizedBox(height: 100), // Spacing for floating nav bar
            ],
          ),
        ),
      ),
    );
  }
}
