import 'package:flutter/material.dart';
import '../../core/cart/cart_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/shop_service.dart';
import '../../core/widgets/app_network_image.dart';
import '../product/product_detail_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: ShopService.instance,
          builder: (context, _) {
            final shop = ShopService.instance;
            final businessName = shop.currentBusiness?.name ?? 'Healthy Paws Store';
            final allProducts = shop.products;
            final categories = shop.categories.isNotEmpty
                ? shop.categories
                : ['All', 'Food', 'Toys', 'Treats', 'Grooming'];

            // Filter products by selected category chip and search query
            final filtered = allProducts.where((p) {
              final matchesFilter = _selectedFilter == 'All' ||
                  p.category.toLowerCase() == _selectedFilter.toLowerCase();
              final matchesSearch = _searchQuery.isEmpty ||
                  p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  p.category.toLowerCase().contains(_searchQuery.toLowerCase());
              return matchesFilter && matchesSearch;
            }).toList();

            return RefreshIndicator(
              color: AppColors.sageGreen,
              onRefresh: () => shop.refresh(),
              child: Column(
                children: [
                  // Top Shop Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                businessName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.mainText,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: AppColors.sageGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${filtered.length} products available',
                                    style: const TextStyle(
                                      color: AppColors.secondaryText,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.sageGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            shop.configuredShopId,
                            style: const TextStyle(
                              color: AppColors.sageGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search pet food, treats, toys...',
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.secondaryText,
                          size: 20,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Filter Chips Horizontal List
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final filter = categories[index];
                        final isSelected = _selectedFilter.toLowerCase() == filter.toLowerCase();

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
                              color: isSelected ? AppColors.sageGreen : AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.sageGreen
                                    : AppColors.outlineVariant.withValues(alpha: 0.4),
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.sageGreen.withValues(alpha: 0.25),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
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

                  const SizedBox(height: 12),

                  // Products Grid or Empty State
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.parchment,
                                    ),
                                    child: const Icon(
                                      Icons.search_off_rounded,
                                      size: 38,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No products found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.mainText,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _searchQuery.isNotEmpty
                                        ? 'No products match "$_searchQuery". Try a different keyword.'
                                        : 'No products in this category for ${shop.currentBusiness?.name ?? "this store"}.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  if (_searchQuery.isNotEmpty || _selectedFilter != 'All')
                                    TextButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                          _selectedFilter = 'All';
                                        });
                                      },
                                      child: const Text(
                                        'Clear filters',
                                        style: TextStyle(
                                          color: AppColors.sageGreen,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 8,
                              bottom: 100, // Space for floating bottom nav
                            ),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.70,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final product = filtered[index];
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
                                      // Product Image
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(19),
                                            ),
                                            child: SizedBox(
                                              height: 125,
                                              width: double.infinity,
                                              child: AppNetworkImage(
                                                imageUrl: product.image,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          if (discount > 0)
                                            Positioned(
                                              top: 8,
                                              left: 8,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 7, vertical: 3),
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

                                      // Details
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

                                                // Add Button
                                                GestureDetector(
                                                  onTap: () {
                                                    CartService.instance.addToCart(product);
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
                                                    width: 30,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      color: AppColors.sageGreen,
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: AppColors.sageGreen.withValues(alpha: 0.3),
                                                          blurRadius: 6,
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
              ),
            );
          },
        ),
      ),
    );
  }
}
