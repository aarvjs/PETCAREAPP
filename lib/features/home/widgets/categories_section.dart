import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';

class CategoriesSection extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onViewAllTap;

  const CategoriesSection({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Dog', 'image': AppAssets.catDog, 'icon': Icons.pets_rounded},
      {'name': 'Cat', 'image': AppAssets.catCat, 'icon': Icons.pets_rounded},
      {'name': 'Food', 'image': AppAssets.catFood, 'icon': Icons.set_meal_rounded},
      {'name': 'Toys', 'image': AppAssets.catToys, 'icon': Icons.sports_tennis_rounded},
      {'name': 'Treats', 'image': AppAssets.catFood, 'icon': Icons.cookie_rounded},
      {'name': 'Grooming', 'image': AppAssets.catDog, 'icon': Icons.content_cut_rounded},
      {'name': 'Healthcare', 'image': AppAssets.catCat, 'icon': Icons.medical_services_rounded},
      {'name': 'Bird', 'image': AppAssets.catDog, 'icon': Icons.flutter_dash_rounded},
      {'name': 'Fish', 'image': AppAssets.catCat, 'icon': Icons.phishing_rounded},
    ];

    return Column(
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Categories',
                style: TextStyle(
                  color: AppColors.mainText,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              GestureDetector(
                onTap: onViewAllTap,
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.primaryPurple,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Horizontal Category Circular List
        SizedBox(
          height: 100,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final catName = cat['name'] as String;
              final isSelected = selectedCategory == catName;

              return GestureDetector(
                onTap: () => onCategorySelected(catName),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      // Circular Image Container
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 64,
                        height: 64,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryPurple
                                : AppColors.skyBlue.withValues(alpha: 0.3),
                            width: isSelected ? 2.5 : 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? AppColors.primaryPurple.withValues(alpha: 0.2)
                                  : AppColors.mainText.withValues(alpha: 0.04),
                              blurRadius: isSelected ? 12 : 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            cat['image'] as String,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Category Label
                      Text(
                        catName,
                        style: TextStyle(
                          color: isSelected ? AppColors.primaryPurple : AppColors.mainText,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
