import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/app_floating_nav.dart';
import '../cart/cart_screen.dart';
import '../clinic/clinic_screen.dart';
import '../home/home_screen.dart';
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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: AppDrawer(
        selectedIndex: _currentIndex,
        onItemSelected: _onTabSelected,
      ),
      body: Stack(
        children: [
          // Indexed Stack for 5 Tabs
          IndexedStack(
            index: _currentIndex,
            children: [
              HomeScreen(
                onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
                onNavigateToTab: _onTabSelected,
              ),
              const ShopScreen(),
              const ClinicScreen(),
              CartScreen(
                onContinueShopping: () => _onTabSelected(1), // Go to Shop tab
              ),
              const ProfileScreen(),
            ],
          ),

          // Floating Animated Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppFloatingNav(
              selectedIndex: _currentIndex,
              onItemSelected: _onTabSelected,
            ),
          ),
        ],
      ),
    );
  }
}
