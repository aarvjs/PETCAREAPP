import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/app_button.dart';
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
        duration: const Duration(milliseconds: 350),
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
    final isLastPage = _currentPage == OnboardingData.items.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Soft Organic Background Aura
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.skyBlue.withValues(alpha: 0.2),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.3,
            right: -50,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lavenderFixed.withValues(alpha: 0.25),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox.expand(),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Header (Brand & Skip)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Brand Identity
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.pets_rounded,
                              size: 16,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Healthy Paws',
                            style: TextStyle(
                              color: AppColors.mainText,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),

                      // Subtle Skip Action
                      TextButton(
                        onPressed: _navigateToLogin,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.secondaryText,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          AppStrings.skip,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content View
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

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const Spacer(flex: 1),

                            // Editorial Pet Image Container (Soft organic curve treatment)
                            Container(
                              height: size.height * 0.42,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(56),
                                  topRight: Radius.circular(24),
                                  bottomLeft: Radius.circular(24),
                                  bottomRight: Radius.circular(56),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.mainText.withValues(alpha: 0.06),
                                    blurRadius: 28,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(56),
                                  topRight: Radius.circular(24),
                                  bottomLeft: Radius.circular(24),
                                  bottomRight: Radius.circular(56),
                                ),
                                child: Image.asset(
                                  item.asset,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            const Spacer(flex: 1),

                            // Natural Editorial Typography
                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.mainText,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                                height: 1.2,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                item.description,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.secondaryText,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w400,
                                  height: 1.45,
                                ),
                              ),
                            ),

                            const Spacer(flex: 2),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Navigation Bar (Dots + CTA Button)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                      // Progress Dot Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          OnboardingData.items.length,
                          (dotIndex) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 6,
                            width: _currentPage == dotIndex ? 22 : 6,
                            decoration: BoxDecoration(
                              color: _currentPage == dotIndex
                                  ? AppColors.sageGreen
                                  : AppColors.outlineVariant.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Primary Action CTA
                      AppButton(
                        text: isLastPage ? 'Get Started' : 'Next',
                        onPressed: _onNextPressed,
                        backgroundColor: AppColors.sageGreen,
                        borderRadius: 16,
                        height: 52,
                        icon: isLastPage ? null : Icons.arrow_forward_rounded,
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
