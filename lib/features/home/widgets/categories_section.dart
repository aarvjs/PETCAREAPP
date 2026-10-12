import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/shop_service.dart';

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

  String _imageForCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('dog')) return AppAssets.catDog;
    if (lower.contains('cat')) return AppAssets.catCat;
    if (lower.contains('food') || lower.contains('treat')) return AppAssets.catFood;
    if (lower.contains('toy')) return AppAssets.catToys;
    return AppAssets.catDog;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ShopService.instance,
      builder: (context, _) {
        final serviceCats = ShopService.instance.categories.where((c) => c != 'All').toList();
        final displayCats = serviceCats.isNotEmpty
            ? serviceCats
            : ['Dog', 'Cat', 'Food', 'Toys', 'Treats', 'Grooming', 'Care'];

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

            // Horizontal Category Circular List
            SizedBox(
              height: 104,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                scrollDirection: Axis.horizontal,
                itemCount: displayCats.length,
                itemBuilder: (context, index) {
                  final catName = displayCats[index];
                  final isSelected = selectedCategory.toLowerCase() == catName.toLowerCase();

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
                                    ? AppColors.sageGreen
                                    : AppColors.outlineVariant.withValues(alpha: 0.35),
                                width: isSelected ? 2.5 : 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? AppColors.sageGreen.withValues(alpha: 0.22)
                                      : AppColors.mainText.withValues(alpha: 0.04),
                                  blurRadius: isSelected ? 12 : 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(
                                    _imageForCategory(catName),
                                    fit: BoxFit.cover,
                                  ),
                                  if (isSelected)
                                    Container(
                                      color: AppColors.sageGreen.withValues(alpha: 0.15),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 7),

                          // Category Label
                          Text(
                            catName,
                            style: TextStyle(
                              color: isSelected ? AppColors.sageGreen : AppColors.mainText,
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
      },
    );
  }
}
