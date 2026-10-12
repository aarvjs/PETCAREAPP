import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';

class HealthcareService {
  final String id;
  final String title;
  final String description;
  final String price;
  final String image;
  final IconData icon;

  const HealthcareService({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.image,
    required this.icon,
  });
}

class HealthcareSection extends StatelessWidget {
  final VoidCallback onViewAllTap;

  const HealthcareSection({
    super.key,
    required this.onViewAllTap,
  });

  static const List<HealthcareService> services = [
    HealthcareService(
      id: 'h1',
      title: 'Vaccination',
      description: 'Protect your pet from common viral diseases.',
      price: 'From ₹499',
      image: AppAssets.onboardingVet,
      icon: Icons.vaccines_rounded,
    ),
    HealthcareService(
      id: 'h2',
      title: 'General Checkup',
      description: 'Comprehensive health exam by certified vet.',
      price: 'From ₹799',
      image: AppAssets.heroSlider3,
      icon: Icons.health_and_safety_rounded,
    ),
    HealthcareService(
      id: 'h3',
      title: 'Deworming Care',
      description: 'Essential parasite treatment & prevention.',
      price: 'From ₹299',
      image: AppAssets.catDog,
      icon: Icons.medication_rounded,
    ),
    HealthcareService(
      id: 'h4',
      title: 'Grooming & Spa',
      description: 'Complete bath, haircut & nail trimming.',
      price: 'From ₹999',
      image: AppAssets.catDog,
      icon: Icons.content_cut_rounded,
    ),
    HealthcareService(
      id: 'h5',
      title: 'Dental Care',
      description: 'Professional teeth cleaning & hygiene.',
      price: 'From ₹599',
      image: AppAssets.catCat,
      icon: Icons.clean_hands_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pet Healthcare',
                style: TextStyle(
                  color: AppColors.mainText,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              GestureDetector(
                onTap: onViewAllTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.sageGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          color: AppColors.sageGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: AppColors.sageGreen,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Services Horizontal Carousel
        SizedBox(
          height: 155,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            scrollDirection: Axis.horizontal,
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];

              return Container(
                width: 240,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(22),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.sageGreen.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            service.icon,
                            size: 20,
                            color: AppColors.sageGreen,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            service.title,
                            style: const TextStyle(
                              color: AppColors.mainText,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      service.description,
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          service.price,
                          style: const TextStyle(
                            color: AppColors.sageGreen,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.sageGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Book Now',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
