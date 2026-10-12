import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/doctor_model.dart';
import '../../../core/services/shop_service.dart';

class ClinicHomeView extends StatelessWidget {
  final VoidCallback onOpenDrawer;
  final Function(int)? onNavigateToTab;

  const ClinicHomeView({
    super.key,
    required this.onOpenDrawer,
    this.onNavigateToTab,
  });

  void _showBookingSheet(BuildContext context, {String? defaultService, String? defaultDoctor}) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final petNameCtrl = TextEditingController();
    String selectedPetType = 'Dog';
    String selectedService = defaultService ?? 'Veterinary Consultation';
    String selectedDoctor = defaultDoctor ?? 'Any Available Specialist';
    String selectedDate = 'Tomorrow';
    String selectedTime = '10:00 AM';

    final services = [
      'Veterinary Consultation',
      'Vaccination & Immunization',
      'General Health Checkup',
      'Deworming & Parasite Care',
      'Pet Grooming & Spa',
      'Dental Care & Cleaning',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            padding: EdgeInsets.only(
              top: 24,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Book Clinic Appointment',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.mainText,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded, color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Pet Type Selector
                  const Text('Pet Type', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Dog', 'Cat', 'Bird', 'Other'].map((type) {
                      final isSel = selectedPetType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(type),
                          selected: isSel,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSel ? AppColors.white : AppColors.mainText,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) => setSheetState(() => selectedPetType = type),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Pet Name & Owner Details
                  TextField(
                    controller: petNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Pet Name',
                      hintText: 'e.g. Bruno',
                      prefixIcon: Icon(Icons.pets_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Your Full Name',
                      hintText: 'e.g. Rahul Sharma',
                      prefixIcon: Icon(Icons.person_outline, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Contact Mobile Number',
                      hintText: 'e.g. 9876543210',
                      prefixIcon: Icon(Icons.phone_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Service Selector
                  const Text('Select Service', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedService,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.medical_services_outlined, size: 20),
                    ),
                    items: services
                        .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 14))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setSheetState(() => selectedService = val);
                    },
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        final pName = petNameCtrl.text.trim().isEmpty ? 'Pet' : petNameCtrl.text.trim();
                        final cName = nameCtrl.text.trim().isEmpty ? 'Customer' : nameCtrl.text.trim();
                        final cPhone = phoneCtrl.text.trim();

                        await ShopService.instance.bookAppointment(
                          customerName: cName,
                          customerPhone: cPhone,
                          petName: pName,
                          petType: selectedPetType,
                          serviceName: selectedService,
                          doctorName: selectedDoctor,
                          appointmentDate: selectedDate,
                          appointmentTime: selectedTime,
                        );

                        if (!context.mounted) return;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Appointment confirmed for $pName at ${ShopService.instance.currentBusiness?.name ?? "the clinic"}!'),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'Confirm Appointment',
                        style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 15),
                      ),
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

  @override
  Widget build(BuildContext context) {
    final biz = ShopService.instance.currentBusiness;
    final doctors = ShopService.instance.doctors;
    final clinicName = biz?.name ?? 'Healthy Paws Clinic';
    final address = biz?.address ?? 'Swaroop Nagar, Kanpur';
    final phone = biz?.phone ?? '+91 98765 43210';
    final timings = biz?.clinicTimings ?? 'Mon - Sat: 09:00 AM - 08:00 PM';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Clinic Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: onOpenDrawer,
                  icon: const Icon(Icons.menu_rounded, color: AppColors.mainText),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              clinicName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.mainText,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'CLINIC',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 12, color: AppColors.secondaryText),
                          const SizedBox(width: 3),
                          Text(
                            address,
                            style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentPeach,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.medical_services_rounded, size: 20, color: AppColors.accentCoral),
                ),
              ],
            ),
          ),

          // 2. Clinic Hero Banner
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified_rounded, size: 14, color: AppColors.white),
                            SizedBox(width: 4),
                            Text(
                              'VERIFIED VETERINARY CLINIC',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Compassionate Medical Care For Your Pets',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Operating Hours: $timings',
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: () => _showBookingSheet(context),
                    icon: const Icon(Icons.calendar_month_rounded, size: 18),
                    label: const Text('Book Appointment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentCoral,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Quick Action Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildQuickActionCard(
                  icon: Icons.vaccines_outlined,
                  title: 'Vaccination',
                  subtitle: 'Core & Rabies',
                  color: AppColors.primaryContainer,
                  iconColor: AppColors.primary,
                  onTap: () => _showBookingSheet(context, defaultService: 'Vaccination & Immunization'),
                ),
                const SizedBox(width: 12),
                _buildQuickActionCard(
                  icon: Icons.health_and_safety_outlined,
                  title: 'Consultation',
                  subtitle: 'General OPD',
                  color: AppColors.accentPeach,
                  iconColor: AppColors.accentCoral,
                  onTap: () => _showBookingSheet(context, defaultService: 'Veterinary Consultation'),
                ),
                const SizedBox(width: 12),
                _buildQuickActionCard(
                  icon: Icons.emergency_outlined,
                  title: 'Emergency',
                  subtitle: phone,
                  color: AppColors.errorContainer,
                  iconColor: AppColors.errorRed,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Clinic Emergency Line: $phone'),
                        backgroundColor: AppColors.errorRed,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. Clinical Services Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Veterinary Services',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.mainText,
                  ),
                ),
                TextButton(
                  onPressed: () => onNavigateToTab?.call(1),
                  child: const Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildServiceCard(
                  title: 'Comprehensive Health Checkup',
                  description: 'Complete physical evaluation, vital signs, teeth, ears & joint analysis.',
                  price: '₹799',
                  icon: Icons.health_and_safety_rounded,
                  onTap: () => _showBookingSheet(context, defaultService: 'General Health Checkup'),
                ),
                _buildServiceCard(
                  title: 'Vaccination & Deworming',
                  description: 'Puppy & adult pet immunization packages with official health certificate.',
                  price: '₹499',
                  icon: Icons.vaccines_rounded,
                  onTap: () => _showBookingSheet(context, defaultService: 'Vaccination & Immunization'),
                ),
                _buildServiceCard(
                  title: 'Dental Cleaning & Tartar Removal',
                  description: 'Ultrasonic scaling, oral hygiene check & fresh breath maintenance.',
                  price: '₹599',
                  icon: Icons.clean_hands_rounded,
                  onTap: () => _showBookingSheet(context, defaultService: 'Dental Care & Cleaning'),
                ),
                _buildServiceCard(
                  title: 'Medicated Pet Grooming & Spa',
                  description: 'Anti-tick bath, ear flushing, hygienic trimming & coat deep cleaning.',
                  price: '₹999',
                  icon: Icons.content_cut_rounded,
                  onTap: () => _showBookingSheet(context, defaultService: 'Pet Grooming & Spa'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 5. Specialist Doctors Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Text(
              'Resident Doctors & Specialists',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.mainText,
              ),
            ),
          ),
          const SizedBox(height: 12),

          if (doctors.isNotEmpty) ...[
            SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: doctors.length,
                separatorBuilder: (_, index) => const SizedBox(width: 14),
                itemBuilder: (ctx, i) => _buildDoctorCard(context, doctors[i]),
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildDefaultDoctorCard(context),
            ),
          ],
          const SizedBox(height: 24),

          // 6. Clinic Contact & Hours Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Clinic Information',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildInfoRow(Icons.access_time_rounded, 'Timings', timings),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.phone_outlined, 'Helpline', phone),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.pin_drop_outlined, 'Address', address),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100), // padding for bottom nav
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: iconColor.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 24, color: iconColor),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.mainText),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String description,
    required String price,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.mainText),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.secondaryText, height: 1.3),
                ),
                const SizedBox(height: 8),
                Text(
                  price,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              elevation: 0,
            ),
            child: const Text('Book', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, DoctorModel doctor) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
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
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryContainer,
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    Text(
                      doctor.qualification,
                      style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            doctor.specialization,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            'Exp: ${doctor.experience}',
            style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: OutlinedButton(
              onPressed: () => _showBookingSheet(context, defaultDoctor: doctor.fullName),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Consult Doctor', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultDoctorCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryContainer,
            child: const Icon(Icons.medical_services, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Resident Veterinary Staff',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                SizedBox(height: 2),
                Text(
                  'BVSc & AH • Available on duty',
                  style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showBookingSheet(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Book'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 10),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.secondaryText),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.mainText),
          ),
        ),
      ],
    );
  }
}
