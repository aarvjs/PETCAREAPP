import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/pet_model.dart';
import '../../core/models/treatment_model.dart';
import '../../core/services/pet_service.dart';
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

            // Vaccination & Treatment History Section (Requirement 7)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Vaccinations & Treatments',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.mainText),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_outlined, size: 14, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            StreamBuilder<List<TreatmentModel>>(
              stream: PetService.instance.streamPetTreatments(pet.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Syncing treatment records...',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final treatments = snapshot.data ?? [];

                if (treatments.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.vaccines_rounded, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No Treatments Recorded Yet',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.mainText),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Vaccination and injection records administered by the authorized clinic doctor for ${pet.name} will appear here in real time.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: AppColors.secondaryText, height: 1.4),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: treatments.map((t) => _buildTreatmentCard(t)).toList(),
                );
              },
            ),
            const SizedBox(height: 24),

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

  Widget _buildTreatmentCard(TreatmentModel t) {
    final hasBooster = t.nextDueDate != null;
    final isUpcoming = t.isUpcomingBooster;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: t.isVaccine
                      ? const Color(0xFFDFF7EE)
                      : AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  t.isVaccine ? Icons.vaccines_rounded : Icons.medication_rounded,
                  color: t.isVaccine ? const Color(0xFF35B779) : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.medicineName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.mainText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${t.medicineCategory} • ${t.quantityUsed.toStringAsFixed(t.quantityUsed.truncateToDouble() == t.quantityUsed ? 0 : 1)} ${t.unit}${t.dosage.isNotEmpty ? ' (${t.dosage})' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F7F0),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF35B779).withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF35B779)),
                    SizedBox(width: 4),
                    Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF35B779),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),

          // Date & Doctor Info
          Row(
            children: [
              const Icon(Icons.event_available_rounded, size: 15, color: AppColors.secondaryText),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Administered: ${t.formattedAdminDate}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.mainText),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.person_pin_rounded, size: 15, color: AppColors.secondaryText),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  t.administeredByName.isNotEmpty ? t.administeredByName : 'Doctor',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ),
            ],
          ),

          // Next Due / Booster Date Banner
          if (hasBooster) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isUpcoming ? AppColors.primaryContainer : const Color(0xFFFFF4E5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isUpcoming
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : const Color(0xFFFF9800).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isUpcoming ? Icons.notifications_active_rounded : Icons.schedule_rounded,
                    size: 14,
                    color: isUpcoming ? AppColors.primary : const Color(0xFFE65100),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isUpcoming
                          ? 'Next Booster Due: ${t.formattedNextDueDate!}'
                          : 'Previous Booster Due: ${t.formattedNextDueDate!}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isUpcoming ? AppColors.primary : const Color(0xFFE65100),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Batch & Clinical Notes
          if (t.batchNumber.isNotEmpty || t.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (t.batchNumber.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'Batch: #${t.batchNumber}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.secondaryText),
                    ),
                  ),
                if (t.notes.isNotEmpty)
                  Expanded(
                    child: Text(
                      t.notes,
                      style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.secondaryText),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ],
        ],
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
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.mainText),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
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
