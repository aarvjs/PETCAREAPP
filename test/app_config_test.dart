import 'package:flutter_test/flutter_test.dart';
import 'package:pet_care/core/config/app_config.dart';
import 'package:pet_care/core/models/business_model.dart';
import 'package:pet_care/core/models/product_model.dart';

void main() {
  group('AppConfig Tests', () {
    test('Default shopId is SHOP-D9E8 when not overridden by dart-define', () {
      expect(AppConfig.defaultShopId, 'SHOP-D9E8');
      expect(AppConfig.shopId, isNotEmpty);
    });

    test('isCustomShopId reflects custom configuration', () {
      // By default without dart-define, shopId equals defaultShopId
      expect(AppConfig.isCustomShopId, isFalse);
    });
  });

  group('BusinessModel Tests', () {
    test('Correctly parses ecommerce and clinic modules from modules array', () {
      final data = {
        'shopId': 'SHOP-D9E8',
        'name': 'Royal Pet clinik',
        'modules': ['ecommerce', 'clinic'],
        'city': 'Kanpur',
      };

      final biz = BusinessModel.fromFirestore(data, 'biz_123');
      expect(biz.shopId, 'SHOP-D9E8');
      expect(biz.name, 'Royal Pet clinik');
      expect(biz.hasEcommerce, isTrue);
      expect(biz.hasClinic, isTrue);
      expect(biz.experience, AppExperience.combined);
    });

    test('Correctly detects ecommerce-only business', () {
      final data = {
        'shopId': 'SHOP-ECOMM',
        'name': 'Pet Foods Only',
        'modules': ['ecommerce'],
      };

      final biz = BusinessModel.fromFirestore(data, 'biz_ecomm');
      expect(biz.hasEcommerce, isTrue);
      expect(biz.hasClinic, isFalse);
      expect(biz.experience, AppExperience.ecommerceOnly);
    });

    test('Correctly detects clinic-only business with published clinic', () {
      final data = {
        'shopId': 'SHOP-CLINIC',
        'name': 'Veterinary Specialty Clinic',
        'modules': ['clinic'],
        'clinicPublished': true,
      };

      final biz = BusinessModel.fromFirestore(data, 'biz_clinic');
      expect(biz.hasEcommerce, isFalse);
      expect(biz.hasClinic, isTrue);
      expect(biz.experience, AppExperience.clinicOnly);
    });

    test('Correctly detects clinicPendingSetup when clinic is in draft', () {
      final data = {
        'shopId': 'SHOP-DRAFT',
        'name': 'New Clinic In Setup',
        'modules': ['clinic'],
        'clinicStatus': 'draft',
      };

      final biz = BusinessModel.fromFirestore(data, 'biz_draft');
      expect(biz.hasClinic, isTrue);
      expect(biz.clinicPublished, isFalse);
      expect(biz.experience, AppExperience.clinicPendingSetup);
    });

    test('Correctly parses modules from assignedAdmins array if modules is missing', () {
      final data = {
        'shopId': 'SHOP-ADMINS',
        'name': 'Admin Config Clinic',
        'assignedAdmins': [
          {'email': 'admin@test.com', 'modules': ['clinic']}
        ],
      };

      final biz = BusinessModel.fromFirestore(data, 'biz_admin');
      expect(biz.hasClinic, isTrue);
      expect(biz.experience, AppExperience.clinicOnly);
    });
  });

  group('ProductModel Tests', () {
    test('Correctly calculates discount and formats Indian Rupee prices', () {
      final product = ProductItem(
        id: 'prod_1',
        name: 'Royal Chain Product',
        category: 'Accessories',
        price: '₹300',
        oldPrice: '₹500',
        image: 'https://firebasestorage.googleapis.com/...',
      );

      expect(product.discountPercent, 40);
      expect(product.priceNumber, 300.0);
    });

    test('Parses Firestore product data properly with sellingPrice and mrp', () {
      final data = {
        'name': 'Royal Chain Product',
        'category': 'Accessories',
        'sellingPrice': 300,
        'mrp': 500,
        'image': 'https://firebasestorage.googleapis.com/test.png',
        'shopId': 'SHOP-D9E8',
      };

      final product = ProductItem.fromFirestore(data, 'prod_test');
      expect(product.name, 'Royal Chain Product');
      expect(product.price, '₹300');
      expect(product.oldPrice, '₹500');
      expect(product.discountPercent, 40);
    });
  });
}
