import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import 'onboarding_data.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _onNextPressed() {
    if (_currentPage < OnboardingData.items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient Glow Backdrop Blobs
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.skyBlue.withValues(alpha: 0.3),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.25,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lavenderFixed.withValues(alpha: 0.4),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: const SizedBox.expand(),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Navigation Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // PetCare Brand Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.9),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.pets_rounded,
                              size: 16,
                              color: AppColors.primaryPurple,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'PetCare',
                              style: TextStyle(
                                color: AppColors.primaryPurple,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Skip Button
                      TextButton(
                        onPressed: _navigateToLogin,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.secondaryText,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        ),
                        child: const Text(
                          AppStrings.skip,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Page View
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: OnboardingData.items.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final item = OnboardingData.items[index];

                      return Column(
                        children: [
                          // Upper Visual Canvas (Photo + Badges)
                          Expanded(
                            flex: 55,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Curved Background Aura
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(36),
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.skyBlue.withValues(alpha: 0.35),
                                          AppColors.lightSky,
                                          AppColors.lavenderFixed.withValues(alpha: 0.5),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                  ),

                                  // High Resolution Pet Photograph Container
                                  Container(
                                    width: size.width * 0.82,
                                    height: size.height * 0.38,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(28),
                                      border: Border.all(
                                        color: AppColors.white.withValues(alpha: 0.9),
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryPurple.withValues(alpha: 0.12),
                                          blurRadius: 24,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: Image.asset(
                                        item.asset,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),

                                  // Top-Left Micro Badge
                                  Positioned(
                                    top: 14,
                                    left: 14,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.white.withValues(alpha: 0.85),
                                        border: Border.all(
                                          color: AppColors.white,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.pets_rounded,
                                        size: 20,
                                        color: AppColors.primaryPurple,
                                      ),
                                    ),
                                  ),

                                  // Top-Right Micro Badge
                                  Positioned(
                                    top: 18,
                                    right: 14,
                                    child: Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.white.withValues(alpha: 0.85),
                                        border: Border.all(
                                          color: AppColors.white,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.medical_services_rounded,
                                        size: 18,
                                        color: AppColors.primaryPurple,
                                      ),
                                    ),
                                  ),

                                  // Overlapping Glass Frosted Card (Bottom)
                                  Positioned(
                                    bottom: 0,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: AppColors.white.withValues(alpha: 0.88),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: AppColors.white.withValues(alpha: 0.9),
                                              width: 1.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primaryPurple
                                                    .withValues(alpha: 0.1),
                                                blurRadius: 16,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 26,
                                                height: 26,
                                                decoration: const BoxDecoration(
                                                  color: AppColors.skyContainer,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.verified_rounded,
                                                  size: 16,
                                                  color: AppColors.primaryPurple,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                item.badgeText,
                                                style: const TextStyle(
                                                  color: AppColors.mainText,
                                                  fontSize: 13,
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
                          ),

                          // Lower Sanctuary Card Area
                          Expanded(
                            flex: 45,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(32),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.mainText.withValues(alpha: 0.04),
                                    blurRadius: 20,
                                    offset: const Offset(0, -6),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      // Category Pill
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: AppColors.skyBlue.withValues(alpha: 0.25),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          item.pillText,
                                          style: const TextStyle(
                                            color: AppColors.primaryPurple,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Title
                                      Text(
                                        item.title,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: AppColors.mainText,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.3,
                                          height: 1.25,
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      // Description
                                      Text(
                                        item.description,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: AppColors.secondaryText,
                                          fontSize: 14,
                                          height: 1.45,
                                        ),
                                      ),

                                      if (item.tags.isNotEmpty) ...[
                                        const SizedBox(height: 14),
                                        Wrap(
                                          spacing: 8,
                                          alignment: WrapAlignment.center,
                                          children: item.tags
                                              .map(
                                                (tag) => Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.softLavender,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    tag,
                                                    style: const TextStyle(
                                                      color: AppColors.primaryPurple,
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ],
                                    ],
                                  ),

                                  // Page Indicator & Floating Circular Action Button
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          // Stepper Dots
                                          Row(
                                            children: List.generate(
                                              OnboardingData.items.length,
                                              (dotIndex) => AnimatedContainer(
                                                duration: const Duration(milliseconds: 300),
                                                margin: const EdgeInsets.only(right: 8),
                                                height: 8,
                                                width: _currentPage == dotIndex ? 28 : 8,
                                                decoration: BoxDecoration(
                                                  color: _currentPage == dotIndex
                                                      ? AppColors.primaryPurple
                                                      : AppColors.softLavender,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Circular Floating Action Button
                                          GestureDetector(
                                            onTap: _onNextPressed,
                                            child: Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    AppColors.primaryPurple,
                                                    AppColors.skyBlue,
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.primaryPurple
                                                        .withValues(alpha: 0.3),
                                                    blurRadius: 16,
                                                    offset: const Offset(0, 6),
                                                  ),
                                                ],
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.arrow_forward_rounded,
                                                  color: AppColors.white,
                                                  size: 26,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      if (_currentPage == OnboardingData.items.length - 1) ...[
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              AppStrings.alreadyHaveAccount,
                                              style: TextStyle(
                                                color: AppColors.secondaryText,
                                                fontSize: 13,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: _navigateToLogin,
                                              child: const Text(
                                                AppStrings.signIn,
                                                style: TextStyle(
                                                  color: AppColors.primaryPurple,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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
