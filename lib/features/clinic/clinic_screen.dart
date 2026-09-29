import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';

class ClinicServiceItem {
  final String id;
  final String name;
  final String description;
  final String price;
  final String image;
  final IconData icon;

  const ClinicServiceItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.icon,
  });
}

class ClinicScreen extends StatefulWidget {
  final bool isViewAllMode;

  const ClinicScreen({
    super.key,
    this.isViewAllMode = false,
  });

  @override
  State<ClinicScreen> createState() => _ClinicScreenState();
}

class _ClinicScreenState extends State<ClinicScreen> {
  static const List<ClinicServiceItem> allServices = [
    ClinicServiceItem(
      id: 'cs1',
      name: 'Vaccination',
      description: 'Core & non-core vaccines for puppies, dogs, kittens & cats.',
      price: 'From ₹499',
      image: AppAssets.onboardingVet,
      icon: Icons.vaccines_rounded,
    ),
    ClinicServiceItem(
      id: 'cs2',
      name: 'General Health Checkup',
      description: 'Comprehensive physical examination & vital signs monitoring.',
      price: 'From ₹799',
      image: AppAssets.heroSlider3,
      icon: Icons.health_and_safety_rounded,
    ),
    ClinicServiceItem(
      id: 'cs3',
      name: 'Deworming & Parasite Care',
      description: 'Flea, tick & internal worm prevention treatments.',
      price: 'From ₹299',
      image: AppAssets.catDog,
      icon: Icons.medication_rounded,
    ),
    ClinicServiceItem(
      id: 'cs4',
      name: 'Pet Grooming & Spa',
      description: 'Medicated bath, coat brushing, ear cleaning & styling.',
      price: 'From ₹999',
      image: AppAssets.catDog,
      icon: Icons.content_cut_rounded,
    ),
    ClinicServiceItem(
      id: 'cs5',
      name: 'Dental Care & Cleaning',
      description: 'Tartar removal, breath freshening & oral health check.',
      price: 'From ₹599',
      image: AppAssets.catCat,
      icon: Icons.clean_hands_rounded,
    ),
    ClinicServiceItem(
      id: 'cs6',
      name: 'Pet Consultation & Diagnosis',
      description: 'Expert veterinary diagnosis for illness & behavioral issues.',
      price: 'From ₹499',
      image: AppAssets.heroSlider3,
      icon: Icons.medical_information_rounded,
    ),
    ClinicServiceItem(
      id: 'cs7',
      name: 'Skin & Coat Treatment',
      description: 'Allergy relief, itching treatment & nutritional care.',
      price: 'From ₹699',
      image: AppAssets.catDog,
      icon: Icons.healing_rounded,
    ),
    ClinicServiceItem(
      id: 'cs8',
      name: 'Nail Trimming & Paw Care',
      description: 'Safe claw clipping & moisturizing paw pad therapy.',
      price: 'From ₹199',
      image: AppAssets.catCat,
      icon: Icons.pets_rounded,
    ),
    ClinicServiceItem(
      id: 'cs9',
      name: 'Preventive Healthcare Plan',
      description: 'Annual wellness package including routine tests & supplements.',
      price: 'From ₹1,499',
      image: AppAssets.onboardingVet,
      icon: Icons.shield_rounded,
    ),
    ClinicServiceItem(
      id: 'cs10',
      name: 'Pet Wellness Checkup',
      description: 'Senior pet care & growth tracking for young pets.',
      price: 'From ₹899',
      image: AppAssets.heroSlider4,
      icon: Icons.favorite_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Clinic Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Pet Healthcare Services',
                    style: TextStyle(
                      color: AppColors.mainText,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Icon(Icons.medical_services_rounded, color: AppColors.primaryPurple, size: 24),
                ],
              ),
              const SizedBox(height: 16),

              // Emergency Triage Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primaryPurple,
                      AppColors.primaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.health_and_safety_rounded, color: AppColors.white, size: 36),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '24/7 Veterinary Clinic',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Certified healthcare for all pets',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Connecting to Clinic Desk...'),
                            backgroundColor: AppColors.primaryPurple,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.primaryPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      child: const Text('Book Care', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Available Healthcare Services Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available Healthcare Services',
                    style: TextStyle(
                      color: AppColors.mainText,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    '${allServices.length} Services',
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

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
                        color: AppColors.skyBlue.withValues(alpha: 0.3),
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
                        // Service Icon Box
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.lightSky,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            service.icon,
                            color: AppColors.primaryPurple,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Service Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.name,
                                style: const TextStyle(
                                  color: AppColors.mainText,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                service.description,
                                style: const TextStyle(
                                  color: AppColors.secondaryText,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                service.price,
                                style: const TextStyle(
                                  color: AppColors.primaryPurple,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Book Action Button
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${service.name} booked successfully!'),
                                backgroundColor: AppColors.successGreen,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.lightSky,
                            foregroundColor: AppColors.primaryPurple,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Book',
                            style: TextStyle(
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
        ),
      ),
    );
  }
}
