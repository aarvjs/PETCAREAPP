import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/business_model.dart';
import '../../core/services/shop_service.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/app_floating_nav.dart';
import '../cart/cart_screen.dart';
import '../clinic/clinic_screen.dart';
import '../home/home_screen.dart';
import '../home/shop_unavailable_screen.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';
import '../shop/shop_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ShopService.instance,
      builder: (context, _) {
        final resState = ShopService.instance.resolutionState;

        // If shop is missing, not found, or inactive, show branded unavailable screen
        if (resState == ShopResolutionState.missingShopId ||
            resState == ShopResolutionState.notFound ||
            resState == ShopResolutionState.inactive) {
          return ShopUnavailableScreen(state: resState);
        }

        final exp = ShopService.instance.experience;
        List<Widget> screens;

        if (exp == AppExperience.clinicOnly) {
          screens = [
            HomeScreen(
              onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
              onNavigateToTab: _onTabSelected,
            ),
            const ClinicScreen(),
            const OrdersScreen(),
            const ProfileScreen(),
          ];
        } else if (exp == AppExperience.ecommerceOnly) {
          screens = [
            HomeScreen(
              onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
              onNavigateToTab: _onTabSelected,
            ),
            const ShopScreen(),
            CartScreen(
              onContinueShopping: () => _onTabSelected(1),
            ),
            const ProfileScreen(),
          ];
        } else {
          // Combined Mode (Both E-Commerce and Clinic enabled & published)
          screens = [
            HomeScreen(
              onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
              onNavigateToTab: _onTabSelected,
            ),
            const ShopScreen(),
            const ClinicScreen(),
            CartScreen(
              onContinueShopping: () => _onTabSelected(1),
            ),
            const ProfileScreen(),
          ];
        }

        // Ensure current index is within bounds if module configuration changed
        final safeIndex = _currentIndex >= screens.length ? 0 : _currentIndex;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.background,
          drawer: AppDrawer(
            selectedIndex: safeIndex,
            onItemSelected: _onTabSelected,
          ),
          body: Stack(
            children: [
              // Indexed Stack for Active Tabs
              IndexedStack(
                index: safeIndex,
                children: screens,
              ),

              // Floating Bottom Navigation Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AppFloatingNav(
                  selectedIndex: safeIndex,
                  onItemSelected: _onTabSelected,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
