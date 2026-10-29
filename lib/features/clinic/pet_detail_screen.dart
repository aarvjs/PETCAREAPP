import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/pet_model.dart';
import '../../core/models/treatment_model.dart';
import '../../core/services/pet_service.dart';
import '../../core/services/shop_service.dart';
import 'appointment_detail_screen.dart';
import 'book_appointment_screen.dart';

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
                  const SizedBox(height: 16),

                  // Book Appointment CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookAppointmentScreen(pet: pet),
                          ),
                        );
                      },
                      icon: const Icon(Icons.calendar_month_rounded, size: 18),
                      label: const Text(
                        'Book Clinic Appointment',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.2),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 1,
                      ),
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

            // Clinic Appointments & Consultations Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Appointments & Visits',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.mainText),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookAppointmentScreen(pet: pet),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                  label: const Text(
                    'New Booking',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: PetService.instance.streamPetAppointments(pet.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                  );
                }

                final appointments = snapshot.data ?? [];
                if (appointments.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.calendar_month_outlined, size: 36, color: AppColors.secondaryText),
                        const SizedBox(height: 8),
                        const Text(
                          'No Appointments Scheduled',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.mainText),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Book a consultation with our veterinary doctor for health checkups, treatments, or vaccinations.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: AppColors.secondaryText, height: 1.4),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookAppointmentScreen(pet: pet),
                              ),
                            );
                          },
                          icon: const Icon(Icons.calendar_today_rounded, size: 16),
                          label: const Text('Book Appointment Now', style: TextStyle(fontWeight: FontWeight.w800)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: appointments.map((apt) => _buildAppointmentCard(context, apt)).toList(),
                );
              },
            ),
            const SizedBox(height: 24),

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
                    if (t.isVaccine && (t.doseNumber != null || t.vaccineBrand != null)) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (t.doseNumber != null && t.doseNumber!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1EEFF),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                t.totalDoses != null
                                    ? '${t.doseNumber} of ${t.totalDoses}'
                                    : t.doseNumber!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          if (t.vaccineBrand != null && t.vaccineBrand!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                'Brand: ${t.vaccineBrand}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isUpcoming
                              ? 'Next Booster Due: ${t.formattedNextDueDate!}'
                              : 'Previous Booster Due: ${t.formattedNextDueDate!}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isUpcoming ? AppColors.primary : const Color(0xFFE65100),
                          ),
                        ),
                        if (t.dosesRemaining != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            t.dosesRemaining == 0
                                ? 'Vaccination series completed'
                                : '${t.dosesRemaining} dose${t.dosesRemaining == 1 ? '' : 's'} remaining in series',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isUpcoming ? AppColors.primary.withValues(alpha: 0.8) : const Color(0xFFE65100),
                            ),
                          ),
                        ],
                      ],
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

  Widget _buildAppointmentCard(BuildContext context, Map<String, dynamic> apt) {
    final status = (apt['status'] ?? 'Pending').toString();
    final aptId = (apt['appointmentId'] ?? apt['id'] ?? '').toString();
    final date = (apt['appointmentDate'] ?? apt['date'] ?? 'TBD').toString();
    final time = (apt['appointmentTime'] ?? apt['time'] ?? 'TBD').toString();
    final doctor = (apt['doctorName'] ?? 'Assigned Doctor').toString();
    final concern = (apt['concernCategory'] ?? apt['serviceName'] ?? 'Consultation').toString();
    final isConfirmed = status.toLowerCase() == 'confirmed';
    final isCompleted = status.toLowerCase() == 'completed';
    final isCancelled = status.toLowerCase() == 'cancelled';

    Color statusColor = AppColors.primary;
    Color statusBg = AppColors.primaryContainer;
    if (isConfirmed) {
      statusColor = AppColors.successGreen;
      statusBg = AppColors.successContainer;
    } else if (isCompleted) {
      statusColor = const Color(0xFF0284C7);
      statusBg = const Color(0xFFE0F2FE);
    } else if (isCancelled) {
      statusColor = AppColors.errorRed;
      statusBg = AppColors.errorContainer;
    }

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                aptId,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  fontFamily: 'monospace',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.event_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                '$date • $time',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.mainText),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.medical_services_outlined, size: 16, color: AppColors.secondaryText),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$concern • $doctor',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (apt['symptoms'] != null && (apt['symptoms'] as String).isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Symptoms: ${apt['symptoms']}',
                style: const TextStyle(fontSize: 11, color: AppColors.mainText),
              ),
            ),
          ],
          if (isCancelled && apt['rejectionReason'] != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Clinic Notice: ${apt['rejectionReason']}',
                style: const TextStyle(fontSize: 11, color: AppColors.errorRed, fontWeight: FontWeight.w600),
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderLight, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AppointmentDetailScreen(
                        appointmentDocId: (apt['id'] ?? '').toString(),
                        initialData: apt,
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Row(
                  children: [
                    Text(
                      'View Booking Details',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                    Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primary),
                  ],
                ),
              ),
              if (isCompleted)
                ElevatedButton.icon(
                  onPressed: () => _showPrescriptionSheet(context, apt),
                  icon: const Icon(Icons.description_outlined, size: 14),
                  label: const Text('Prescription (PDF)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    elevation: 0,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPrescriptionSheet(BuildContext context, Map<String, dynamic> apt) {
    final treatment = (apt['treatment'] is Map)
        ? Map<String, dynamic>.from(apt['treatment'] as Map)
        : <String, dynamic>{};

    final doctor = (treatment['doctorName'] ?? apt['doctorName'] ?? 'Dr. Ashwani Kumar Singh').toString();
    final doctorReg = (treatment['doctorRegdNo'] ?? 'UPVC 6394').toString();
    final doctorQual = (treatment['doctorQualifications'] ?? 'B.V.Sc & A.H (RAJUVAS Bikaner)').toString();
    final temp = (treatment['temperature'] ?? '').toString();
    final weight = (treatment['weight'] ?? '').toString();
    final signs = (treatment['clinicalSigns'] ?? '').toString();
    final diagnosis = (treatment['diagnosis'] ?? apt['diagnosis'] ?? 'Clinical examination').toString();
    final advice = (treatment['advice'] ?? 'Routine care & rest').toString();
    final nextVisit = (treatment['nextVisitDate'] ?? apt['nextVisitDate'] ?? '').toString();

    final administered = (treatment['administeredItems'] is List) ? (treatment['administeredItems'] as List) : [];
    final prescribed = (treatment['prescribedItems'] is List) ? (treatment['prescribedItems'] as List) : [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header: Clinic & Doctor
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Healthy Paws Pet Clinic',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.mainText),
                    ),
                    Text(
                      'Official Clinical Prescription Report (PDF Slip)',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0284C7)),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(color: AppColors.border, height: 20),

            // Scrollable Clinical Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor Details
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_user_rounded, color: Color(0xFF0284C7), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(doctor,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.mainText)),
                                Text('$doctorQual • Regd No: $doctorReg',
                                    style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Patient Bar
                    Text(
                      'Patient: ${pet.name} (${pet.breed}) • Age: ${pet.ageDisplay} • ${pet.gender}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.mainText),
                    ),
                    const SizedBox(height: 14),

                    // Vitals Grid
                    const Text('Clinical Examination & Vitals',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.mainText)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          if (temp.isNotEmpty) _buildPrescriptionRow('Temperature', temp),
                          if (weight.isNotEmpty) _buildPrescriptionRow('Weight', weight),
                          if (signs.isNotEmpty) _buildPrescriptionRow('Clinical Signs', signs),
                          _buildPrescriptionRow('Diagnosis', diagnosis, isBold: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Rx Injections
                    if (administered.isNotEmpty) ...[
                      const Text('Rx - Administered Treatments & Injections',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.mainText)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: administered.map((item) {
                            final name = (item is Map) ? (item['name'] ?? 'Medicine').toString() : 'Medicine';
                            final dosage = (item is Map) ? (item['dosage'] ?? '').toString() : '';
                            final route = (item is Map) ? (item['route'] ?? 'IM').toString() : 'IM';
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.successGreen),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text('Inj. $name $dosage $route',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Take-Home Prescriptions
                    if (prescribed.isNotEmpty) ...[
                      const Text('Take-Home Prescribed Medications',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.mainText)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: prescribed.map((item) {
                            final name = (item is Map) ? (item['name'] ?? 'Medicine').toString() : 'Medicine';
                            final dosage = (item is Map) ? (item['dosage'] ?? '').toString() : '';
                            final inst = (item is Map) ? (item['instructions'] ?? '').toString() : '';
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.medication_outlined, size: 16, color: Color(0xFF0284C7)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('$name ($dosage)',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                                        if (inst.isNotEmpty)
                                          Text(inst, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Advice & Next Visit
                    const Text('Clinical Advice & Follow-Up',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.mainText)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Advice: $advice', style: const TextStyle(fontSize: 12, height: 1.4)),
                          if (nextVisit.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text('Next Visit Due: $nextVisit',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0284C7))),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Legal Disclaimer
                    const Text(
                      'Disclaimer: This prescription is issued based on clinical judgment and available investigations. Follow-up evaluation is advised as recommended.',
                      style: TextStyle(fontSize: 10, color: AppColors.secondaryText, fontStyle: FontStyle.italic, height: 1.3),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
                color: isBold ? const Color(0xFF0284C7) : AppColors.mainText,
              ),
            ),
          ),
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
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : 'Not provided',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mainText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
