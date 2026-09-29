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
    this.variants = const [],
    this.variantPrices,
    this.specifications = const {},
  });

  List<String> get galleryImages => images.isNotEmpty ? images : [image];
}

// Sample enriched product catalog helper
class ProductData {
  static ProductItem enrichProduct(ProductItem p) {
    if (p.description.isNotEmpty) return p;

    // Detailed defaults based on product ID/category
    switch (p.id) {
      case 'p1':
      case 's1':
        return ProductItem(
          id: p.id,
          name: p.name,
          category: p.category,
          price: p.price,
          oldPrice: p.oldPrice,
          image: p.image,
          images: [
            p.image,
            AppAssets.catCat,
            AppAssets.catFood,
          ],
          subtitle: 'Holistic grain-free recipe for active pets',
          description:
              'Crafted with real premium chicken, nutritious green peas, and essential vitamins. Formulated by veterinary nutritionists to support optimal digestion, shiny coats, and lean muscle maintenance. 100% natural with no artificial preservatives or fillers.',
          inStock: true,
          variants: ['500g', '1kg', '2.5kg', '5kg'],
          variantPrices: {
            '500g': '\$12.99',
            '1kg': '\$22.50',
            '2.5kg': '\$28.99',
            '5kg': '\$49.99',
          },
          specifications: {
            'Brand': 'NutriPet Prime',
            'Category': 'Pet Food',
            'Pet Type': 'Dogs & Cats',
            'Weight': '2.5 kg',
            'Suitable For': 'All Breeds & Life Stages',
            'Shelf Life': '18 Months',
          },
        );
      case 'p2':
      case 's2':
        return ProductItem(
          id: p.id,
          name: p.name,
          category: p.category,
          price: p.price,
          oldPrice: p.oldPrice,
          image: p.image,
          images: [
            p.image,
            AppAssets.catToys,
          ],
          subtitle: 'Durable non-toxic natural rubber toy',
          description:
              'Designed for endless hours of fun and mental stimulation. Helps massage gums and maintain dental hygiene while satisfying your pet’s natural urge to chew. Built with reinforced non-toxic eco-friendly rubber.',
          inStock: true,
          variants: ['Small', 'Medium', 'Large'],
          variantPrices: {
            'Small': '\$9.99',
            'Medium': '\$14.50',
            'Large': '\$19.99',
          },
          specifications: {
            'Brand': 'PawPlay Fun',
            'Category': 'Toys',
            'Pet Type': 'Dogs',
            'Material': 'BPA-free Natural Rubber',
            'Suitable For': 'Medium to Large Breeds',
          },
        );
      case 'p3':
      case 's3':
        return ProductItem(
          id: p.id,
          name: p.name,
          category: p.category,
          price: p.price,
          oldPrice: p.oldPrice,
          image: p.image,
          images: [
            p.image,
            AppAssets.catFood,
          ],
          subtitle: 'Crunchy Omega-3 enriched salmon bites',
          description:
              'Irresistible crispy treats loaded with wild-caught salmon and essential Omega-3 fatty acids. Ideal for training rewards and coat health enrichment.',
          inStock: true,
          variants: ['100g Pack', '250g Pack'],
          variantPrices: {
            '100g Pack': '\$5.99',
            '250g Pack': '\$9.99',
          },
          specifications: {
            'Brand': 'OceanBites',
            'Category': 'Treats',
            'Pet Type': 'Cats & Puppies',
            'Weight': '250g',
            'Key Benefit': 'Coat & Joint Support',
          },
        );
      case 'p4':
      case 's4':
        return ProductItem(
          id: p.id,
          name: p.name,
          category: p.category,
          price: p.price,
          oldPrice: p.oldPrice,
          image: p.image,
          images: [
            p.image,
            AppAssets.catDog,
          ],
          subtitle: 'Hypoallergenic soothing botanical shampoo',
          description:
              'Formulated with organic colloidal oatmeal and aloe vera to relieve itchy, dry skin. Gentle tear-free formula leaves coat soft, shiny, and pleasantly scented.',
          inStock: true,
          variants: ['250ml', '500ml'],
          variantPrices: {
            '250ml': '\$12.50',
            '500ml': '\$18.25',
          },
          specifications: {
            'Brand': 'PureGroom Organic',
            'Category': 'Grooming',
            'Pet Type': 'All Pets',
            'Volume': '500ml',
            'Formula': 'Soap-free & Paraben-free',
          },
        );
      case 's5':
        return ProductItem(
          id: p.id,
          name: p.name,
          category: p.category,
          price: p.price,
          oldPrice: p.oldPrice,
          image: p.image,
          images: [
            p.image,
            AppAssets.catDog,
          ],
          subtitle: 'Genuine padded leather with heavy-duty zinc alloy hardware',
          description:
              'Handcrafted top-grain leather leash and collar set engineered for durability, comfort, and style. Features soft inner padding to prevent neck chaffing.',
          inStock: true,
          variants: ['Medium', 'Large'],
          variantPrices: {
            'Medium': '\$28.00',
            'Large': '\$32.00',
          },
          specifications: {
            'Brand': 'UrbanPaw Luxe',
            'Category': 'Care & Accessories',
            'Pet Type': 'Dogs',
            'Material': 'Genuine Leather & Alloy',
          },
        );
      case 's6':
        return ProductItem(
          id: p.id,
          name: p.name,
          category: p.category,
          price: p.price,
          oldPrice: p.oldPrice,
          image: p.image,
          images: [
            p.image,
            AppAssets.catFood,
          ],
          subtitle: 'Daily immune & hip joint chewables',
          description:
              'Daily nutritional chewables packed with 21 essential vitamins, minerals, and glucosamine for joint health and energetic vitality.',
          inStock: true,
          variants: ['60 Soft Chews', '120 Soft Chews'],
          variantPrices: {
            '60 Soft Chews': '\$16.80',
            '120 Soft Chews': '\$28.50',
          },
          specifications: {
            'Brand': 'VetiHealth',
            'Category': 'Supplements',
            'Pet Type': 'Dogs & Cats',
            'Count': '60 Soft Chews',
          },
        );
      default:
        return ProductItem(
          id: p.id,
          name: p.name,
          category: p.category,
          price: p.price,
          oldPrice: p.oldPrice,
          image: p.image,
          images: [p.image],
          subtitle: 'Premium pet essential',
          description:
              'High quality product tailored specifically for your pet’s health, happiness, and overall well-being.',
          inStock: true,
          variants: const [],
          specifications: {
            'Category': p.category,
            'Pet Type': 'Dogs & Cats',
          },
        );
    }
  }
}
