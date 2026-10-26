import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/service_model.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/shop_service.dart';
import 'book_appointment_screen.dart';
import 'pet_registration_screen.dart';

class ClinicScreen extends StatefulWidget {
  final bool isViewAllMode;
  final VoidCallback? onNavigateToShop;

  const ClinicScreen({
    super.key,
    this.isViewAllMode = false,
    this.onNavigateToShop,
  });

  @override
  State<ClinicScreen> createState() => _ClinicScreenState();
}

class _ClinicScreenState extends State<ClinicScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleBookService(ServiceModel service) {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to book a veterinary appointment'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pushNamed(AppRoutes.login);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookAppointmentScreen(
          preSelectedService: service.name,
          servicePrice: service.price > 0 ? service.price : null,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('consult')) return Icons.medical_information_rounded;
    if (cat.contains('vaccin') || cat.contains('prevent')) return Icons.vaccines_rounded;
    if (cat.contains('groom') || cat.contains('spa')) return Icons.content_cut_rounded;
    if (cat.contains('dent')) return Icons.clean_hands_rounded;
    if (cat.contains('surg')) return Icons.healing_rounded;
    if (cat.contains('diagnos') || cat.contains('lab')) return Icons.biotech_rounded;
    return Icons.health_and_safety_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: ShopService.instance,
          builder: (context, _) {
            final hasClinic = ShopService.instance.hasClinic;
            final business = ShopService.instance.currentBusiness;
            final clinicName = business?.name ?? 'Healthy Paws Pet Clinic';

            if (!hasClinic) {
              return _buildClinicDisabledView(clinicName);
            }

            return StreamBuilder<List<ServiceModel>>(
              stream: ShopService.instance.streamServices(),
              builder: (context, snapshot) {
                final allServices = snapshot.data ?? [];
                final isLoading = snapshot.connectionState == ConnectionState.waiting && allServices.isEmpty;
                final hasError = snapshot.hasError;

                // Extract unique categories
                final categorySet = <String>{'All'};
                for (final s in allServices) {
                  if (s.category.trim().isNotEmpty) {
                    categorySet.add(s.category.trim());
                  }
                }
                final categories = categorySet.toList();

                // Apply filters
                final filteredServices = allServices.where((s) {
                  final matchesCat = _selectedCategory == 'All' ||
                      s.category.trim().toLowerCase() == _selectedCategory.toLowerCase();
                  if (!matchesCat) return false;

                  if (_searchQuery.isEmpty) return true;
                  final q = _searchQuery.toLowerCase();
                  final matchName = s.name.toLowerCase().contains(q);
                  final matchDesc = s.description.toLowerCase().contains(q);
                  final matchCategory = s.category.toLowerCase().contains(q);
                  return matchName || matchDesc || matchCategory;
                }).toList();

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Sticky Header with Clinic Title & Badges
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
                        child: _buildTopHeader(clinicName),
                      ),
                    ),

                    // Top Hero Banner (~20% Screen Height)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: _buildHeroBanner(context),
                      ),
                    ),

                    // Search Services Input Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                        child: _buildSearchBar(),
                      ),
                    ),

                    // Horizontal Category Chips
                    if (categories.length > 1)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildCategoryChips(categories),
                        ),
                      ),

                    // Section Heading: "Our Services"
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Our Services',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.mainText,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${filteredServices.length}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_searchQuery.isNotEmpty || _selectedCategory != 'All')
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _searchQuery = '';
                                    _searchController.clear();
                                    _selectedCategory = 'All';
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  child: Text(
                                    'Reset Filters',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Services List / States
                    if (isLoading)
                      const SliverToBoxAdapter(child: _ServicesLoadingSkeleton())
                    else if (hasError)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: _buildErrorState(snapshot.error.toString()),
                        ),
                      )
                    else if (filteredServices.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: _buildEmptyState(allServices.isEmpty),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 80),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final service = filteredServices[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildServiceCard(service),
                              );
                            },
                            childCount: filteredServices.length,
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // --- TOP HEADER ---
  Widget _buildTopHeader(String clinicName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Clinic & Care',
                style: TextStyle(
                  color: AppColors.mainText,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                clinicName,
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1EEFF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDDD7FF), width: 0.8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_rounded, size: 14, color: AppColors.primary),
              SizedBox(width: 5),
              Text(
                'Verified Vets',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- TOP HERO BANNER (~20% Screen Height) ---
  Widget _buildHeroBanner(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final bannerHeight = (screenHeight * 0.20).clamp(155.0, 185.0);

    return Container(
      height: bannerHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.asset(
              'assets/images/clinic_hero_banner.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF7567E8),
                child: const Center(
                  child: Icon(Icons.pets_rounded, size: 64, color: Colors.white24),
                ),
              ),
            ),

            // Subtle Gradient Overlay to ensure readable text
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.82),
                    Colors.black.withValues(alpha: 0.60),
                    Colors.black.withValues(alpha: 0.15),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),

            // Content Overlay
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Headline & Supporting line
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 0.6),
                        ),
                        child: const Text(
                          'PREMIUM VETERINARY CARE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Care That Keeps\nTails Wagging',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.15,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Compassionate veterinary checkups & wellness programs.',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Colors.white.withValues(alpha: 0.88),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  // Register Your Pet Action Button
                  SizedBox(
                    height: 34,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PetRegistrationScreen()),
                        );
                      },
                      icon: const Icon(Icons.app_registration_rounded, size: 14, color: AppColors.primary),
                      label: const Text(
                        'Register Your Pet',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.primary,
                        elevation: 2,
                        shadowColor: Colors.black38,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SEARCH SERVICES BAR ---
  Widget _buildSearchBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val.trim();
          });
        },
        style: const TextStyle(fontSize: 13, color: AppColors.mainText, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
          hintText: 'Search veterinary services...',
          hintStyle: const TextStyle(fontSize: 12, color: AppColors.secondaryText, fontWeight: FontWeight.w400),
          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.secondaryText),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  // --- CATEGORY CHIPS ---
  Widget _buildCategoryChips(List<String> categories) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory.toLowerCase() == cat.toLowerCase();

          return InkWell(
            onTap: () {
              setState(() {
                _selectedCategory = cat;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (cat != 'All') ...[
                    Icon(
                      _getCategoryIcon(cat),
                      size: 13,
                      color: isSelected ? AppColors.white : AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    cat,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? AppColors.white : AppColors.mainText,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- POLISHED SERVICE CARD ---
  Widget _buildServiceCard(ServiceModel service) {
    final catIcon = _getCategoryIcon(service.category);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Image or Designed Fallback
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE9E5FF), width: 0.8),
                  ),
                  child: service.image.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            service.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Icon(catIcon, color: AppColors.primary, size: 28),
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(catIcon, color: AppColors.primary, size: 28),
                        ),
                ),
                const SizedBox(width: 12),

                // Details: Name, Category, Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1EEFF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              service.category.isNotEmpty ? service.category.toUpperCase() : 'HEALTHCARE',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          if (service.duration.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.schedule_rounded, size: 10, color: AppColors.secondaryText),
                                const SizedBox(width: 3),
                                Text(
                                  service.duration,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.mainText,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        service.description.isNotEmpty
                            ? service.description
                            : 'Professional veterinary healthcare provided by registered clinic specialists.',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.secondaryText,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(color: AppColors.borderLight, height: 1),
            const SizedBox(height: 10),

            // Bottom Bar: Price & Book Appointment Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Consultation Fee',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    Text(
                      service.formattedPrice,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _handleBookService(service),
                  icon: const Icon(Icons.calendar_month_rounded, size: 14),
                  label: const Text(
                    'Book Appointment',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 1,
                    shadowColor: AppColors.primary.withValues(alpha: 0.3),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- EMPTY STATES ---
  Widget _buildEmptyState(bool isNoServicesConfigured) {
    if (isNoServicesConfigured) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1EEFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_hospital_outlined, size: 28, color: AppColors.primary),
              ),
              const SizedBox(height: 14),
              const Text(
                'Services Updating',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.mainText),
              ),
              const SizedBox(height: 6),
              const Text(
                'Healthy Paws Pet Clinic is updating its list of veterinary treatments. You can still register your pet in the meantime.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.secondaryText, height: 1.4),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PetRegistrationScreen()),
                  );
                },
                icon: const Icon(Icons.app_registration_rounded, size: 15),
                label: const Text('Register Your Pet', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // No search results match
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded, size: 40, color: AppColors.secondaryText),
            const SizedBox(height: 12),
            const Text(
              'No Matching Services Found',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.mainText),
            ),
            const SizedBox(height: 4),
            Text(
              'We couldn\'t find any services matching "$_searchQuery". Try searching for consultation, vaccination, or grooming.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.secondaryText, height: 1.4),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedCategory = 'All';
                });
              },
              child: const Text('Clear Search Filter', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD1D1)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.errorRed, size: 32),
          const SizedBox(height: 10),
          const Text(
            'Unable to Load Clinic Services',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.mainText),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicDisabledView(String businessName) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFF1EEFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                size: 38,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Clinic Services Not Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.mainText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$businessName currently offers e-commerce pet products only.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicesLoadingSkeleton extends StatelessWidget {
  const _ServicesLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
