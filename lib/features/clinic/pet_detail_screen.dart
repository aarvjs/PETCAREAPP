import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/pet_model.dart';
import '../../core/services/shop_service.dart';

class PetDetailScreen extends StatelessWidget {
  final PetModel pet;

  const PetDetailScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final biz = ShopService.instance.currentBusiness;
    final clinicName = biz?.name ?? 'Healthy Paws Pet Clinic';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          pet.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.mainText,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.mainText),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Pet Card with Image & Official Badge
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Photo or Avatar
                  Center(
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: pet.photoUrl != null && pet.photoUrl!.isNotEmpty
                            ? Image.network(
                                pet.photoUrl!,
                                width: 110,
                                height: 110,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.pets_rounded,
                                  size: 48,
                                  color: AppColors.primary,
                                ),
                              )
                            : const Icon(
                                Icons.pets_rounded,
                                size: 48,
                                color: AppColors.primary,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Name & Species
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.mainText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${pet.species} • ${pet.breed} • ${pet.gender}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Registration Number Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'REG: ${pet.registrationNumber}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Pet Biological Attributes Grid
            const Text(
              'Pet Attributes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.mainText),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    title: 'Coat Colour',
                    value: pet.coatColour.isNotEmpty ? pet.coatColour : 'Not specified',
                    icon: Icons.palette_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    title: 'Date of Birth',
                    value: pet.dob.isNotEmpty ? pet.dob : 'Not specified',
                    subtitle: pet.ageDisplay,
                    icon: Icons.cake_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    title: 'Species / Type',
                    value: pet.species,
                    icon: Icons.category_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    title: 'Gender',
                    value: pet.gender,
                    icon: Icons.transgender_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Owner Information
            const Text(
              'Owner & Guardian Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.mainText),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildDetailRow(Icons.person_outline, 'Owner Name', pet.ownerName),
                  const Divider(color: AppColors.border, height: 20),
                  _buildDetailRow(Icons.phone_outlined, 'Contact Phone', pet.contactNumber),
                  const Divider(color: AppColors.border, height: 20),
                  _buildDetailRow(Icons.location_on_outlined, 'Owner Address', pet.ownerAddress),
                  const Divider(color: AppColors.border, height: 20),
                  _buildDetailRow(Icons.local_hospital_outlined, 'Registered Clinic', clinicName),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Medical Notes / Clinical Status
            if (pet.medicalNotes != null && pet.medicalNotes!.isNotEmpty) ...[
              const Text(
                'Veterinary Clinical Notes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.mainText),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  pet.medicalNotes!,
                  style: const TextStyle(fontSize: 13, color: AppColors.mainText, height: 1.4),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Back to Clinic Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Back to Clinic', style: TextStyle(fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.mainText),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
              ),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : 'Not provided',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.mainText),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
