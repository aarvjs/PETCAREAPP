import 'package:flutter/material.dart';
import '../../../core/cart/cart_service.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/product_model.dart';
import '../../product/product_detail_screen.dart';

// Re-export ProductItem so legacy imports continue working seamlessly
export '../../../core/models/product_model.dart';

class TopProductsSection extends StatelessWidget {
  final String selectedCategory;
  final VoidCallback onViewAllTap;
  final Function(ProductItem)? onAddToCart;

  const TopProductsSection({
    super.key,
    required this.selectedCategory,
    required this.onViewAllTap,
    this.onAddToCart,
  });

  static const List<ProductItem> allProducts = [
    ProductItem(
      id: 'p1',
      name: 'Chicken & Green Pea Recipe',
      category: 'Food',
      price: '\$28.99',
      oldPrice: '\$34.99',
      image: AppAssets.catFood,
    ),
    ProductItem(
      id: 'p2',
      name: 'Interactive Tug & Chew Toy',
      category: 'Toys',
      price: '\$14.50',
      oldPrice: '\$18.00',
      image: AppAssets.catToys,
    ),
    ProductItem(
      id: 'p3',
      name: 'Salmon Crunchy Treats',
      category: 'Treats',
      price: '\$9.99',
      oldPrice: '\$12.99',
      image: AppAssets.catCat,
    ),
    ProductItem(
      id: 'p4',
      name: 'Organic Oat Grooming Shampoo',
      category: 'Grooming',
      price: '\$18.25',
      oldPrice: '\$22.00',
      image: AppAssets.catDog,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Filter products based on selected category if applicable
    final filtered = selectedCategory == 'Dog' || selectedCategory == 'Cat'
        ? allProducts
        : allProducts.where((p) => p.category.toLowerCase() == selectedCategory.toLowerCase()).toList();
    final displayProducts = filtered.isEmpty ? allProducts : filtered;

    return Column(
      children: [
        // Header Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Selling',
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

        // Product Cards Carousel
        SizedBox(
          height: 220,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            scrollDirection: Axis.horizontal,
            itemCount: displayProducts.length,
            itemBuilder: (context, index) {
              final product = displayProducts[index];

              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  );
                },
                child: Container(
                  width: 156,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
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
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image Container
                      Container(
                        height: 115,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(19),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(19),
                          ),
                          child: Image.asset(
                            product.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Product Details Content
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.mainText,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.price,
                                      style: const TextStyle(
                                        color: AppColors.primaryPurple,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      product.oldPrice,
                                      style: const TextStyle(
                                        color: AppColors.outlineVariant,
                                        fontSize: 10,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ),

                                // Circular Add Button
                                GestureDetector(
                                  onTap: () {
                                    CartService.instance.addToCart(product);
                                    onAddToCart?.call(product);
                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${product.name} added to cart!'),
                                        backgroundColor: AppColors.primaryPurple,
                                        duration: const Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryPurple,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryPurple.withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.add_rounded,
                                      color: AppColors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
