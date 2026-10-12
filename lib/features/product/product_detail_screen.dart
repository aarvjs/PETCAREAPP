import 'package:flutter/material.dart';
import '../../core/cart/cart_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/product_model.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/app_network_image.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductItem product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ProductItem _enrichedProduct;
  late PageController _pageController;
  int _currentImageIndex = 0;
  String? _selectedVariant;
  int _quantity = 1;
  bool _isWishlisted = false;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _enrichedProduct = ProductData.enrichProduct(widget.product);
    _pageController = PageController();
    if (_enrichedProduct.variants.isNotEmpty) {
      _selectedVariant = _enrichedProduct.variants.first;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String get _currentPrice {
    if (_selectedVariant != null &&
        _enrichedProduct.variantPrices != null &&
        _enrichedProduct.variantPrices!.containsKey(_selectedVariant)) {
      return _enrichedProduct.variantPrices![_selectedVariant]!;
    }
    return _enrichedProduct.price;
  }

  int _calculateDiscountPercentage(String currentPriceStr, String oldPriceStr) {
    final cur = double.tryParse(currentPriceStr.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
    final old = double.tryParse(oldPriceStr.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
    if (old > cur && old > 0) {
      return (((old - cur) / old) * 100).round();
    }
    return 0;
  }

  void _onAddToCart() {
    CartService.instance.addToCart(
      _enrichedProduct,
      variant: _selectedVariant,
      quantity: _quantity,
    );

    final variantText = _selectedVariant != null ? ' ($_selectedVariant)' : '';
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Added $_quantity x ${_enrichedProduct.name}$variantText to Cart!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.sageGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onBuyNow() {
    CartService.instance.addToCart(
      _enrichedProduct,
      variant: _selectedVariant,
      quantity: _quantity,
    );

    // Navigate to MainNav with Cart tab (index 3)
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.mainNav,
      (route) => false,
    );
  }

  void _shareProduct() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share Product',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.mainText,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.copy_rounded, color: AppColors.primaryPurple),
              title: const Text('Copy product link'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product link copied to clipboard!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded, color: AppColors.skyBlue),
              title: const Text('Share via apps'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gallery = _enrichedProduct.galleryImages;
    final discount = _calculateDiscountPercentage(_currentPrice, _enrichedProduct.oldPrice);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.mainText, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.mainText, size: 22),
            onPressed: _shareProduct,
          ),
          IconButton(
            icon: Icon(
              _isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isWishlisted ? Colors.redAccent : AppColors.mainText,
              size: 24,
            ),
            onPressed: () {
              setState(() {
                _isWishlisted = !_isWishlisted;
              });
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isWishlisted
                        ? '${_enrichedProduct.name} added to Favorites'
                        : 'Removed from Favorites',
                  ),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Main Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // GALLERY SECTION
                  _buildGallerySection(gallery),

                  const SizedBox(height: 16),

                  // PRODUCT TITLE, CATEGORY, PRICE & STOCK SECTION
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subtitle / Category Badge
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _enrichedProduct.category.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.primaryPurple,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Stock Status
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _enrichedProduct.inStock
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: _enrichedProduct.inStock ? Colors.green : Colors.red,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _enrichedProduct.inStock ? 'In Stock' : 'Out of Stock',
                                    style: TextStyle(
                                      color: _enrichedProduct.inStock
                                          ? Colors.green.shade800
                                          : Colors.red.shade800,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Product Name
                        Text(
                          _enrichedProduct.name,
                          style: const TextStyle(
                            color: AppColors.mainText,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            height: 1.25,
                          ),
                        ),

                        if (_enrichedProduct.subtitle.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            _enrichedProduct.subtitle,
                            style: const TextStyle(
                              color: AppColors.outlineVariant,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],

                        const SizedBox(height: 14),

                        // Price & Discount Block
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.skyBlue.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _currentPrice,
                                style: const TextStyle(
                                  color: AppColors.primaryPurple,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (_enrichedProduct.oldPrice.isNotEmpty) ...[
                                Text(
                                  _enrichedProduct.oldPrice,
                                  style: const TextStyle(
                                    color: AppColors.outlineVariant,
                                    fontSize: 15,
                                    decoration: TextDecoration.lineThrough,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 10),
                              ],
                              if (discount > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.green.shade200),
                                  ),
                                  child: Text(
                                    '$discount% OFF',
                                    style: TextStyle(
                                      color: Colors.green.shade800,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // VARIANTS SELECTOR (If available)
                  if (_enrichedProduct.variants.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Size / Variant',
                            style: TextStyle(
                              color: AppColors.mainText,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _enrichedProduct.variants.map((v) {
                              final isSelected = _selectedVariant == v;
                              return ChoiceChip(
                                label: Text(v),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedVariant = v;
                                    });
                                  }
                                },
                                selectedColor: AppColors.primaryContainer,
                                backgroundColor: AppColors.white,
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.primaryPurple
                                      : AppColors.outlineVariant.withValues(alpha: 0.5),
                                  width: isSelected ? 2 : 1,
                                ),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? AppColors.primaryPurple
                                      : AppColors.mainText,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                  fontSize: 13,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // QUANTITY SELECTOR
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Quantity',
                          style: TextStyle(
                            color: AppColors.mainText,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.skyBlue.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 18),
                                color: _quantity > 1
                                    ? AppColors.primaryPurple
                                    : AppColors.outlineVariant,
                                onPressed: _quantity > 1
                                    ? () => setState(() => _quantity--)
                                    : null,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  '$_quantity',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.mainText,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 18),
                                color: AppColors.primaryPurple,
                                onPressed: () => setState(() => _quantity++),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // DELIVERY AVAILABILITY CARD
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.lightSky.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_shipping_outlined,
                              color: AppColors.primaryPurple,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Deliver to Swaroop Nagar, Kanpur',
                                  style: TextStyle(
                                    color: AppColors.mainText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'In stock • Standard delivery available',
                                  style: TextStyle(
                                    color: AppColors.outlineVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ABOUT THIS PRODUCT (DESCRIPTION)
                  if (_enrichedProduct.description.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'About this product',
                            style: TextStyle(
                              color: AppColors.mainText,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _enrichedProduct.description,
                            maxLines: _isDescriptionExpanded ? 100 : 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.mainText,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          if (_enrichedProduct.description.length > 120) ...[
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isDescriptionExpanded = !_isDescriptionExpanded;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Text(
                                  _isDescriptionExpanded ? 'Read Less' : 'Read More',
                                  style: const TextStyle(
                                    color: AppColors.primaryPurple,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // PRODUCT SPECIFICATIONS CARD
                  if (_enrichedProduct.specifications.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Product Details',
                            style: TextStyle(
                              color: AppColors.mainText,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.skyBlue.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              children: _enrichedProduct.specifications.entries.map((entry) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: AppColors.surfaceContainerLow,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: const TextStyle(
                                          color: AppColors.outlineVariant,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          entry.value,
                                          textAlign: TextAlign.end,
                                          style: const TextStyle(
                                            color: AppColors.mainText,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // STICKY BOTTOM ACTION BAR
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mainText.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // Buy Now Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _onBuyNow,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.sageGreen, width: 1.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Buy Now',
                        style: TextStyle(
                          color: AppColors.sageGreen,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Add to Cart Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onAddToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.sageGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 3,
                        shadowColor: AppColors.sageGreen.withValues(alpha: 0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGallerySection(List<String> gallery) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 280,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mainText.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: gallery.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return AppNetworkImage(
                      imageUrl: gallery[index],
                      fit: BoxFit.contain,
                    );
                  },
                ),
              ),
            ),

            // Image Counter Badge
            if (gallery.length > 1)
              Positioned(
                bottom: 20,
                right: 28,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentImageIndex + 1} / ${gallery.length}',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),

        // Thumbnails Bar
        if (gallery.length > 1)
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: gallery.length,
              itemBuilder: (context, index) {
                final isSelected = _currentImageIndex == index;
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 54,
                    height: 54,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.sageGreen
                            : AppColors.outlineVariant.withValues(alpha: 0.35),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AppNetworkImage(
                        imageUrl: gallery[index],
                        fit: BoxFit.cover,
                      ),
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
