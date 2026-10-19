import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/pet_model.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/pet_service.dart';
import 'pet_detail_screen.dart';
import 'pet_registration_screen.dart';

class MyPetsScreen extends StatelessWidget {
  const MyPetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.mainText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Registered Pets',
          style: TextStyle(
            color: AppColors.mainText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PetRegistrationScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
                label: const Text(
                  'Register Pet',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.softSage,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
            ),
        ],
      ),
      body: user == null
          ? _buildLoggedOutView(context)
          : StreamBuilder<List<PetModel>>(
              stream: PetService.instance.streamCustomerPets(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.errorRed),
                          const SizedBox(height: 12),
                          const Text(
                            'Unable to load your pets',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.mainText),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final pets = snapshot.data ?? [];

                if (pets.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: pets.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final pet = pets[index];
                    return _buildPetCard(context, pet);
                  },
                );
              },
            ),
    );
  }

  Widget _buildLoggedOutView(BuildContext context) {
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
                shape: BoxShape.circle,
                color: AppColors.softSage,
              ),
              child: const Icon(Icons.pets_rounded, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sign In to View Your Pets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.mainText),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please login with your mobile number to access your registered pets, medical IDs, and clinic history.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.secondaryText, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.login);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Login to Account', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.softSage.withValues(alpha: 0.6),
                border: Border.all(color: AppColors.sageGreen.withValues(alpha: 0.3), width: 2),
              ),
              child: const Icon(Icons.pets_rounded, size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Registered Pets Yet',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.mainText,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Register your dog, cat, or other pets with our clinic to obtain an official sequential Registration Number (HPPC/P/01) and clinical identity.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PetRegistrationScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.app_registration_rounded, size: 20),
              label: const Text(
                'Register Your Pet Now',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetCard(BuildContext context, PetModel pet) {
    final hasPhoto = pet.photoUrl != null && pet.photoUrl!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.mainText.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PetDetailScreen(pet: pet),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pet Avatar / Photo
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 72,
                    height: 72,
                    color: AppColors.softSage,
                    child: hasPhoto
                        ? Image.network(
                            pet.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(pet.species),
                          )
                        : _buildPlaceholderIcon(pet.species),
                  ),
                ),
                const SizedBox(width: 14),

                // Pet Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Registration Badge & Status
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                            ),
                            child: Text(
                              pet.registrationNumber,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: AppColors.sageGreen.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              pet.status,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.sageGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Pet Name
                      Text(
                        pet.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.mainText,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Species & Breed
                      Text(
                        '${pet.species} • ${pet.breed}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Chips: Gender & Coat
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _buildMiniChip(pet.gender),
                          _buildMiniChip(pet.coatColour),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryText, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon(String species) {
    IconData icon = Icons.pets_rounded;
    final s = species.toLowerCase();
    if (s.contains('cat')) icon = Icons.cruelty_free_rounded;
    if (s.contains('bird')) icon = Icons.flutter_dash_rounded;

    return Center(
      child: Icon(icon, color: AppColors.primary, size: 32),
    );
  }

  Widget _buildMiniChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.parchment,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.mainText,
        ),
      ),
    );
  }
}
