import 'package:flutter/material.dart';
import '../../../core/cart/cart_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/product_model.dart';
import '../../../core/services/shop_service.dart';
import '../../../core/widgets/app_network_image.dart';
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ShopService.instance,
      builder: (context, _) {
        final allProducts = ShopService.instance.products;

        // Filter products based on selected category if applicable
        final filtered = (selectedCategory == 'Dog' || selectedCategory == 'Cat' || selectedCategory == 'All')
            ? allProducts
            : allProducts
                .where((p) => p.category.toLowerCase() == selectedCategory.toLowerCase())
                .toList();
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
                    'Best Sellers',
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

            // Product Cards Carousel
            if (displayProducts.isEmpty)
              Container(
                height: 140,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.parchment,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: const Center(
                  child: Text(
                    'No products available right now.',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 232,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  scrollDirection: Axis.horizontal,
                  itemCount: displayProducts.length,
                  itemBuilder: (context, index) {
                    final product = displayProducts[index];
                    final discount = product.discountPercent;

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(product: product),
                          ),
                        );
                      },
                      child: Container(
                        width: 160,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image Container
                            Stack(
                              children: [
                                Container(
                                  height: 120,
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: AppColors.parchment,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(19),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(19),
                                    ),
                                    child: AppNetworkImage(
                                      imageUrl: product.image,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),

                                // Discount Badge
                                if (discount > 0)
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.warmCoral,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '$discount% OFF',
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
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
                                  const SizedBox(height: 6),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.price,
                                              style: const TextStyle(
                                                color: AppColors.sageGreen,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            if (product.oldPrice.isNotEmpty)
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
                                      ),

                                      // Circular Add Button
                                      GestureDetector(
                                        onTap: () {
                                          CartService.instance.addToCart(product);
                                          onAddToCart?.call(product);
                                          ScaffoldMessenger.of(context).clearSnackBars();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  const Icon(Icons.check_circle_rounded,
                                                      color: AppColors.white, size: 18),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text('${product.name} added to cart!'),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor: AppColors.sageGreen,
                                              duration: const Duration(seconds: 1),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: AppColors.sageGreen,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.sageGreen.withValues(alpha: 0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.add_rounded,
                                            color: AppColors.white,
                                            size: 20,
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
      },
    );
  }
}
