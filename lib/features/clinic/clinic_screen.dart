import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/shop_service.dart';
import '../../core/routes/app_routes.dart';
import 'appointment_detail_screen.dart';

class ClinicServiceItem {
  final String id;
  final String name;
  final String description;
  final String price;
  final IconData icon;

  const ClinicServiceItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
  });
}

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
  static const List<ClinicServiceItem> allServices = [
    ClinicServiceItem(
      id: 'cs1',
      name: 'Vaccination & Immunization',
      description: 'Core & non-core vaccines for puppies, dogs, kittens & cats.',
      price: 'From ₹499',
      icon: Icons.vaccines_rounded,
    ),
    ClinicServiceItem(
      id: 'cs2',
      name: 'General Health Checkup',
      description: 'Comprehensive physical examination & vital signs monitoring.',
      price: 'From ₹799',
      icon: Icons.health_and_safety_rounded,
    ),
    ClinicServiceItem(
      id: 'cs3',
      name: 'Deworming & Parasite Care',
      description: 'Flea, tick & internal worm prevention treatments.',
      price: 'From ₹299',
      icon: Icons.medication_rounded,
    ),
    ClinicServiceItem(
      id: 'cs4',
      name: 'Pet Grooming & Medicated Spa',
      description: 'Medicated bath, coat brushing, ear cleaning & styling.',
      price: 'From ₹999',
      icon: Icons.content_cut_rounded,
    ),
    ClinicServiceItem(
      id: 'cs5',
      name: 'Dental Care & Cleaning',
      description: 'Tartar removal, breath freshening & oral health check.',
      price: 'From ₹599',
      icon: Icons.clean_hands_rounded,
    ),
    ClinicServiceItem(
      id: 'cs6',
      name: 'Veterinary Consultation',
      description: 'Expert diagnosis for illness & nutritional advice.',
      price: 'From ₹499',
      icon: Icons.medical_information_rounded,
    ),
  ];

  void _bookService(ClinicServiceItem service) async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in with your phone number to book an appointment'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pushNamed(AppRoutes.login);
      return;
    }

    final profile = AuthService.instance.currentUserProfile;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Book Clinic Appointment',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Confirm booking for ${service.name} at ${ShopService.instance.currentBusiness?.name ?? "Healthy Paws Clinic"}?',
          style: const TextStyle(fontSize: 14, color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final refId = await ShopService.instance.bookAppointment(
          userId: user.uid,
          customerName: profile?.name ?? 'Valued Pet Parent',
          customerPhone: profile?.phoneNumber ?? user.phoneNumber ?? '',
          petName: 'Pet Patient',
          petType: 'Dog',
          serviceName: service.name,
          appointmentDate: 'Tomorrow',
          appointmentTime: '10:00 AM',
        );

        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AppointmentDetailScreen(appointmentDocId: refId),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book appointment: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
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
            final businessName = ShopService.instance.currentBusiness?.name ?? 'Healthy Paws Clinic';

            if (!hasClinic) {
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
                          color: AppColors.parchment,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.medical_services_outlined,
                          size: 40,
                          color: AppColors.secondaryText,
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

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Clinic Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Clinic & Care',
                            style: TextStyle(
                              color: AppColors.mainText,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            businessName,
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.sageGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified_outlined, size: 14, color: AppColors.sageGreen),
                            SizedBox(width: 4),
                            Text(
                              'Verified Vets',
                              style: TextStyle(
                                color: AppColors.sageGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Services List
                  Column(
                    children: allServices.map((service) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.mainText.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.softSage,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                service.icon,
                                color: AppColors.sageGreen,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.name,
                                    style: const TextStyle(
                                      color: AppColors.mainText,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    service.description,
                                    style: const TextStyle(
                                      color: AppColors.secondaryText,
                                      fontSize: 11,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    service.price,
                                    style: const TextStyle(
                                      color: AppColors.sageGreen,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            ElevatedButton(
                              onPressed: () => _bookService(service),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.sageGreen,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Book',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
