import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/shop_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final startTime = DateTime.now();
    const minSplashDuration = Duration(milliseconds: 2000);

    // Initialize shop data in parallel
    final shopFuture = ShopService.instance.initialize();

    String targetRoute = AppRoutes.onboarding;

    try {
      final user = AuthService.instance.currentUser;
      if (user != null) {
        final profile = await AuthService.instance.getUserProfile(user.uid);
        if (profile != null && AuthService.instance.isPrivilegedRole(profile.role)) {
          await AuthService.instance.signOut();
          targetRoute = AppRoutes.login;
        } else if (profile != null &&
            (profile.profileCompleted ||
                profile.profileSkipped ||
                (profile.name != null && profile.name!.trim().isNotEmpty))) {
          // Existing customer with profile or skipped status goes directly to Home
          targetRoute = AppRoutes.mainNav;
        } else {
          // New customer: navigate to optional profile setup
          await AuthService.instance.createOrEnsureMinProfile(user.uid, user.phoneNumber ?? '');
          targetRoute = AppRoutes.profileSetup;
        }
      }
    } catch (_) {
      targetRoute = AppRoutes.onboarding;
    }

    try {
      await shopFuture;
    } catch (_) {}

    final elapsed = DateTime.now().difference(startTime);
    if (elapsed < minSplashDuration) {
      await Future.delayed(minSplashDuration - elapsed);
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, targetRoute);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2), // Warm soft off-white background matching reference
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 3D Glossy Paw Print Centerpiece
                    Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Image.asset(
                        AppAssets.splashPawLogo,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // App Title: "Healthy Paws"
                    const Text(
                      'Healthy Paws',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF2B2D42),
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        height: 1.15,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // App Subtitle: "Pet Clinic" (Vibrant Golden-Amber Accent)
                    const Text(
                      'Pet Clinic',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFF59E0B),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subtle Tagline
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3EDE4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Care. Comfort. Trust.',
                        style: TextStyle(
                          color: Color(0xFF718096),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
