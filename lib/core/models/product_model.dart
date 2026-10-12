import '../constants/app_assets.dart';

class ProductItem {
  final String id;
  final String name;
  final String category;
  final String price;
  final String oldPrice;
  final String image;
  final List<String> images;
  final String description;
  final String subtitle;
  final bool inStock;
  final String? shopId;
  final String? businessId;
  final bool isBestSeller;
  final bool isFeatured;
  final List<String> variants;
  final Map<String, String>? variantPrices;
  final Map<String, String> specifications;

  const ProductItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.oldPrice,
    required this.image,
    this.images = const [],
    this.description = '',
    this.subtitle = '',
    this.inStock = true,
    this.shopId,
    this.businessId,
    this.isBestSeller = false,
    this.isFeatured = false,
    this.variants = const [],
    this.variantPrices,
    this.specifications = const {},
  });

  List<String> get galleryImages => images.isNotEmpty ? images : [image];

  /// Numeric price for cart calculation
  double get priceNumber {
    final clean = price.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(clean) ?? 0.0;
  }

  /// Numeric old/MRP price
  double get oldPriceNumber {
    final clean = oldPrice.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(clean) ?? 0.0;
  }

  /// Calculates percentage discount if both prices are valid
  int get discountPercent {
    if (oldPriceNumber > priceNumber && oldPriceNumber > 0) {
      return (((oldPriceNumber - priceNumber) / oldPriceNumber) * 100).round();
    }
    return 0;
  }

  /// Factory constructor to parse Firestore product documents
  factory ProductItem.fromFirestore(Map<String, dynamic> data, String docId) {
    // 1. Resolve primary image
    String primaryImg = '';
    List<String> imgList = [];

    if (data['primaryImage'] is String && (data['primaryImage'] as String).isNotEmpty) {
      primaryImg = data['primaryImage'];
    } else if (data['image'] is String && (data['image'] as String).isNotEmpty) {
      primaryImg = data['image'];
    }

    if (data['images'] is List) {
      for (final item in data['images'] as List) {
        if (item is Map && item['url'] is String && (item['url'] as String).isNotEmpty) {
          imgList.add(item['url']);
        } else if (item is String && item.isNotEmpty) {
          imgList.add(item);
        }
      }
    }

    if (primaryImg.isEmpty && imgList.isNotEmpty) {
      primaryImg = imgList.first;
    }
    if (primaryImg.isEmpty) {
      primaryImg = AppAssets.catFood;
    }
    if (!imgList.contains(primaryImg)) {
      imgList.insert(0, primaryImg);
    }

    // 2. Resolve price strings (standardized in ₹)
    String priceStr = '₹0';
    if (data['sellingPrice'] != null) {
      priceStr = '₹${data['sellingPrice']}';
    } else if (data['price'] != null) {
      final p = data['price'].toString();
      priceStr = p.startsWith('₹') || p.startsWith('\$') ? p : '₹$p';
    }

    String oldPriceStr = '';
    if (data['mrp'] != null) {
      oldPriceStr = '₹${data['mrp']}';
    } else if (data['oldPrice'] != null) {
      final op = data['oldPrice'].toString();
      oldPriceStr = op.startsWith('₹') || op.startsWith('\$') ? op : '₹$op';
    }

    // 3. Resolve stock status
    bool stockStatus = true;
    if (data['stock'] is num) {
      stockStatus = (data['stock'] as num) > 0;
    } else if (data['stockQuantity'] is num) {
      stockStatus = (data['stockQuantity'] as num) > 0;
    } else if (data['inStock'] is bool) {
      stockStatus = data['inStock'] as bool;
    }

    // 4. Resolve specifications
    final Map<String, String> specs = {};
    if (data['brand'] != null) specs['Brand'] = data['brand'].toString();
    if (data['petType'] != null) specs['Pet Type'] = data['petType'].toString();
    if (data['breedSuitability'] != null) specs['Breed'] = data['breedSuitability'].toString();
    if (data['shelfLife'] != null) specs['Shelf Life'] = data['shelfLife'].toString();
    if (data['countryOfOrigin'] != null) specs['Origin'] = data['countryOfOrigin'].toString();

    return ProductItem(
      id: docId,
      name: data['name'] ?? data['title'] ?? 'Pet Product',
      category: data['category'] ?? 'Pet Care',
      price: priceStr,
      oldPrice: oldPriceStr,
      image: primaryImg,
      images: imgList,
      description: data['fullDescription'] ?? data['description'] ?? data['shortDescription'] ?? '',
      subtitle: data['shortDescription'] ?? data['subtitle'] ?? '',
      inStock: stockStatus,
      shopId: data['shopId'],
      businessId: data['businessId'],
      isBestSeller: data['isBestSeller'] == true,
      isFeatured: data['isFeatured'] == true,
      specifications: specs,
    );
  }
}

// Curated enriched fallback catalog for offline or initialization preview
class ProductData {
  static List<ProductItem> get fallbackProducts => const [
        ProductItem(
          id: 'p1',
          name: 'Royal Holistic Chicken & Peas',
          category: 'Food',
          price: '₹480',
          oldPrice: '₹599',
          image: AppAssets.catFood,
          subtitle: 'Veterinarian formulated balanced nutrition',
          description:
              'Premium farm-raised chicken with nutritious green peas and essential amino acids. Supports healthy skin, shiny coat, and vibrant energy for adult dogs.',
          inStock: true,
          isBestSeller: true,
          isFeatured: true,
          specifications: {
            'Brand': 'Healthy Paws',
            'Category': 'Pet Food',
            'Pet Type': 'Dogs',
            'Weight': '1.2 kg',
            'Shelf Life': '18 Months',
          },
        ),
        ProductItem(
          id: 'p2',
          name: 'Natural Rubber Chew Toy',
          category: 'Toys',
          price: '₹280',
          oldPrice: '₹350',
          image: AppAssets.catToys,
          subtitle: 'Dental care & playful entertainment',
          description:
              'Durable, food-grade natural rubber designed to clean gums and withstand energetic chewers. Safe, non-toxic, and dishwasher safe.',
          inStock: true,
          isBestSeller: true,
          specifications: {
            'Brand': 'Healthy Paws',
            'Category': 'Toys',
            'Pet Type': 'All Pets',
            'Material': 'Natural Rubber',
          },
        ),
        ProductItem(
          id: 'p3',
          name: 'Crunchy Salmon Training Bites',
          category: 'Treats',
          price: '₹220',
          oldPrice: '₹260',
          image: AppAssets.catCat,
          subtitle: 'Rich in Omega-3 and natural proteins',
          description:
              'Bite-sized, oven-baked salmon treats perfect for obedience training or daily rewarding. Grain-free recipe without artificial fillers.',
          inStock: true,
          specifications: {
            'Brand': 'Healthy Paws',
            'Category': 'Treats',
            'Pet Type': 'Dogs & Cats',
          },
        ),
        ProductItem(
          id: 'p4',
          name: 'Oatmeal & Aloe Soothing Shampoo',
          category: 'Grooming',
          price: '₹340',
          oldPrice: '₹420',
          image: AppAssets.catDog,
          subtitle: 'Gentle pH-balanced sensitive skin formula',
          description:
              'Relieves dry, itchy skin with organic oatmeal extract, aloe vera, and provitamin B5. Leaves coats soft, moisturized, and pleasantly fresh.',
          inStock: true,
          specifications: {
            'Brand': 'Healthy Paws',
            'Category': 'Grooming',
            'Volume': '300 ml',
          },
        ),
      ];

  static ProductItem enrichProduct(ProductItem p) {
    if (p.description.isNotEmpty) return p;
    final match = fallbackProducts.where((e) => e.id == p.id).firstOrNull;
    return match ?? p;
  }
}
