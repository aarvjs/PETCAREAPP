import 'package:flutter/material.dart';
import '../../core/cart/cart_service.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/product_model.dart';
import '../product/product_detail_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Food', 'Toys', 'Treats', 'Grooming', 'Care'];

  static const List<ProductItem> _shopProducts = [
    ProductItem(
      id: 's1',
      name: 'Chicken & Green Pea Recipe',
      category: 'Food',
      price: '\$28.99',
      oldPrice: '\$34.99',
      image: AppAssets.catFood,
    ),
    ProductItem(
      id: 's2',
      name: 'Interactive Tug & Chew Toy',
      category: 'Toys',
      price: '\$14.50',
      oldPrice: '\$18.00',
      image: AppAssets.catToys,
    ),
    ProductItem(
      id: 's3',
      name: 'Salmon Crunchy Treats',
      category: 'Treats',
      price: '\$9.99',
      oldPrice: '\$12.99',
      image: AppAssets.catCat,
    ),
    ProductItem(
      id: 's4',
      name: 'Organic Oat Grooming Shampoo',
      category: 'Grooming',
      price: '\$18.25',
      oldPrice: '\$22.00',
      image: AppAssets.catDog,
    ),
    ProductItem(
      id: 's5',
      name: 'Premium Leather Leash & Collar Set',
      category: 'Care',
      price: '\$32.00',
      oldPrice: '\$40.00',
      image: AppAssets.catDog,
    ),
    ProductItem(
      id: 's6',
      name: 'Wellness Multi-Vitamin Treats',
      category: 'Treats',
      price: '\$16.80',
      oldPrice: '\$20.00',
      image: AppAssets.catFood,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedFilter == 'All'
        ? _shopProducts
        : _shopProducts.where((p) => p.category == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Pet Care Shop',
                    style: TextStyle(
                      color: AppColors.mainText,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Icon(Icons.search_rounded, color: AppColors.mainText, size: 24),
                ],
              ),
            ),

            // Search & Filter Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search food, toys, supplies...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.secondaryText),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune_rounded, color: AppColors.white, size: 18),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Filter Chips Horizontal List
            SizedBox(
              height: 38,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryPurple : AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryPurple : AppColors.skyBlue.withValues(alpha: 0.3),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryPurple.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? AppColors.white : AppColors.mainText,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Product Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final product = filtered[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                    child: Container(
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
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                              child: SizedBox(
                                width: double.infinity,
                                child: Image.asset(product.image, fit: BoxFit.cover),
                              ),
                            ),
                          ),
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
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      product.price,
                                      style: const TextStyle(
                                        color: AppColors.primaryPurple,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        CartService.instance.addToCart(product);
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
                                        width: 28,
                                        height: 28,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryPurple,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.add_rounded, color: AppColors.white, size: 16),
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
        ),
      ),
    );
  }
}
