import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../cart/cart_service.dart';
import '../config/app_config.dart';
import '../models/business_model.dart';
import '../models/doctor_model.dart';
import '../models/product_model.dart';

/// Resolution state of the active tenant business
enum ShopResolutionState {
  initial,
  loading,
  ready,
  missingShopId,
  notFound,
  inactive,
}

/// Centralized repository and service managing Shop ID resolution,
/// business metadata, tenant-scoped product catalog, doctors, and order creation.
class ShopService extends ChangeNotifier {
  ShopService._();
  static final ShopService instance = ShopService._();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  BusinessModel? _currentBusiness;
  ShopResolutionState _resolutionState = ShopResolutionState.initial;
  List<ProductItem> _products = [];
  List<DoctorModel> _doctors = [];
  List<String> _categories = ['All', 'Food', 'Toys', 'Treats', 'Grooming'];
  bool _isLoading = false;
  String? _errorMessage;

  BusinessModel? get currentBusiness => _currentBusiness;
  ShopResolutionState get resolutionState => _resolutionState;
  List<ProductItem> get products => List.unmodifiable(_products);
  List<DoctorModel> get doctors => List.unmodifiable(_doctors);
  List<String> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get configuredShopId => AppConfig.shopId;

  /// The active customer application experience based on enabled & published modules
  AppExperience get experience =>
      _currentBusiness?.experience ?? AppExperience.unavailable;

  /// Whether current business has active online e-commerce catalog
  bool get hasEcommerce => _currentBusiness?.hasEcommerce ?? true;

  /// Whether current business has active clinic / veterinary doctor services
  bool get hasClinic => _currentBusiness?.hasClinic ?? true;

  /// Whether clinic is fully published and ready for appointments
  bool get isClinicReady => _currentBusiness?.isClinicReady ?? false;

  /// Initialize and load business profile, catalog, and doctors based on configured Shop ID
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    _resolutionState = ShopResolutionState.loading;
    notifyListeners();

    try {
      await _loadBusiness();

      if (_resolutionState == ShopResolutionState.ready && _currentBusiness != null) {
        if (_currentBusiness!.hasEcommerce) {
          await _loadProducts();
        } else {
          _products = [];
        }

        if (_currentBusiness!.hasClinic) {
          await _loadDoctors();
        } else {
          _doctors = [];
        }
      }
    } catch (e) {
      debugPrint('[ShopService Error] $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resolves the canonical business document from Firestore strictly for the configured Shop ID.
  /// Never falls back to another shop or loads all businesses' data.
  Future<void> _loadBusiness() async {
    final targetShopId = configuredShopId.trim();

    if (targetShopId.isEmpty) {
      _resolutionState = ShopResolutionState.missingShopId;
      _currentBusiness = null;
      return;
    }

    try {
      // 1. Primary lookup: Query businesses where shopId == configuredShopId
      final shopQuery = await _firestore
          .collection('businesses')
          .where('shopId', isEqualTo: targetShopId)
          .limit(1)
          .get();

      if (shopQuery.docs.isNotEmpty) {
        final doc = shopQuery.docs.first;
        final biz = BusinessModel.fromFirestore(doc.data(), doc.id);
        if (!biz.isActive) {
          _currentBusiness = biz;
          _resolutionState = ShopResolutionState.inactive;
          return;
        }
        _currentBusiness = biz;
        _resolutionState = ShopResolutionState.ready;
        return;
      }

      // 2. Secondary lookup: Query businesses by canonical document ID directly
      final docDirect = await _firestore.collection('businesses').doc(targetShopId).get();
      if (docDirect.exists && docDirect.data() != null) {
        final biz = BusinessModel.fromFirestore(docDirect.data()!, docDirect.id);
        if (!biz.isActive) {
          _currentBusiness = biz;
          _resolutionState = ShopResolutionState.inactive;
          return;
        }
        _currentBusiness = biz;
        _resolutionState = ShopResolutionState.ready;
        return;
      }

      // 3. If in debug mode and using default SHOP-D9E8, provide clean development fallback
      if (targetShopId == AppConfig.defaultShopId) {
        _currentBusiness = BusinessModel.fallback(shopId: targetShopId);
        _resolutionState = ShopResolutionState.ready;
        return;
      }

      // Strict multi-tenant isolation: No falling back to arbitrary shops
      _currentBusiness = null;
      _resolutionState = ShopResolutionState.notFound;
    } catch (e) {
      debugPrint('[ShopService] Business lookup error: $e');
      if (targetShopId == AppConfig.defaultShopId) {
        _currentBusiness = BusinessModel.fallback(shopId: targetShopId);
        _resolutionState = ShopResolutionState.ready;
      } else {
        _currentBusiness = null;
        _resolutionState = ShopResolutionState.notFound;
      }
    }
  }

  /// Fetches products scoped strictly to the current Shop ID and business ID
  Future<void> _loadProducts() async {
    final biz = _currentBusiness;
    if (biz == null || !biz.hasEcommerce) {
      _products = [];
      return;
    }

    final targetShopId = biz.shopId;
    final targetBizId = biz.id;

    try {
      final snap = await _firestore.collection('products').get();
      final loaded = <ProductItem>[];

      for (final doc in snap.docs) {
        final data = doc.data();
        final pShopId = (data['shopId'] ?? '').toString();
        final pBizId = (data['businessId'] ?? '').toString();

        // Strict isolation: Product must match current business or shop ID
        // (or default shop if unassigned legacy data)
        final matchesShop = (pShopId.isNotEmpty && pShopId == targetShopId) ||
            (pBizId.isNotEmpty && pBizId == targetBizId) ||
            (targetShopId == AppConfig.defaultShopId && pShopId.isEmpty && pBizId.isEmpty);

        final isPublished = data['isPublished'] != false;

        if (matchesShop && isPublished) {
          loaded.add(ProductItem.fromFirestore(data, doc.id));
        }
      }

      if (loaded.isNotEmpty) {
        _products = loaded;

        // Extract categories dynamically
        final dynamicCats = <String>{'All'};
        for (final p in loaded) {
          if (p.category.isNotEmpty) {
            dynamicCats.add(p.category);
          }
        }
        _categories = dynamicCats.toList();
      } else {
        // Fallback demo products for primary shop if catalog is empty
        if (targetShopId == AppConfig.defaultShopId) {
          _products = ProductData.fallbackProducts;
        } else {
          _products = [];
        }
      }
    } catch (e) {
      debugPrint('[ShopService] Products fetch error: $e');
      if (targetShopId == AppConfig.defaultShopId) {
        _products = ProductData.fallbackProducts;
      }
    }
  }

  /// Fetches doctors scoped strictly to the current Shop ID or business
  Future<void> _loadDoctors() async {
    final biz = _currentBusiness;
    if (biz == null || !biz.hasClinic) {
      _doctors = [];
      return;
    }

    try {
      final snap = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .get();

      final list = <DoctorModel>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        final dShopId = (data['shopId'] ?? '').toString();
        final dBizId = (data['businessId'] ?? '').toString();

        final matches = (dShopId.isNotEmpty && dShopId == biz.shopId) ||
            (dBizId.isNotEmpty && dBizId == biz.id) ||
            (biz.shopId == AppConfig.defaultShopId && dShopId.isEmpty && dBizId.isEmpty);

        if (matches) {
          list.add(DoctorModel.fromFirestore(data, doc.id));
        }
      }
      _doctors = list;
    } catch (e) {
      debugPrint('[ShopService] Doctors fetch notice: $e');
    }
  }

  /// Books a veterinary appointment in Firestore
  Future<String> bookAppointment({
    required String userId,
    required String customerName,
    required String customerPhone,
    required String petName,
    required String petType,
    required String serviceName,
    String? doctorId,
    String? doctorName,
    required String appointmentDate,
    required String appointmentTime,
    String? notes,
  }) async {
    final biz = _currentBusiness;
    final appointmentId = 'APT-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    final data = {
      'appointmentId': appointmentId,
      'userId': userId,
      'shopId': biz?.shopId ?? configuredShopId,
      'businessId': biz?.id ?? '',
      'businessName': biz?.name ?? 'Healthy Paws Clinic',
      'customerName': customerName.trim(),
      'customerPhone': customerPhone.trim(),
      'petName': petName.trim(),
      'petType': petType.trim(),
      'serviceName': serviceName.trim(),
      'doctorId': doctorId ?? '',
      'doctorName': doctorName?.trim() ?? 'Any Available Specialist',
      'appointmentDate': appointmentDate,
      'appointmentTime': appointmentTime,
      'notes': notes?.trim() ?? '',
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final ref = await _firestore.collection('appointments').add(data);
    return ref.id;
  }

  /// Refreshes catalog and business data
  Future<void> refresh() async {
    await initialize();
  }

  /// Creates and submits a new order to Firestore
  Future<String> submitOrder({
    required String userId,
    required String customerName,
    required String customerPhone,
    required String deliveryAddress,
    required String city,
    String? houseOrFlat,
    String? streetOrLocality,
    String? landmark,
    String? state,
    String? pincode,
    String? deliveryInstructions,
    Map<String, dynamic>? shippingAddress,
    required List<CartLineItem> items,
    required double subtotal,
    required double deliveryFee,
    required double totalAmount,
    String paymentMethod = 'Cash on Delivery',
  }) async {
    final biz = _currentBusiness;
    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    final serializedItems = items.map((line) {
      return {
        'productId': line.product.id,
        'name': line.product.name,
        'price': line.effectivePriceString,
        'unitPrice': line.unitPriceNumber,
        'quantity': line.quantity,
        'total': line.totalPrice,
        'variant': line.selectedVariant,
        'image': line.product.image,
      };
    }).toList();

    // Snapshot of delivery address to prevent future profile updates from modifying this order
    final addressSnapshot = shippingAddress ?? {
      'recipientName': customerName.trim(),
      'phoneNumber': customerPhone.trim(),
      'houseOrFlat': houseOrFlat?.trim() ?? '',
      'streetOrLocality': streetOrLocality?.trim() ?? '',
      'landmark': landmark?.trim() ?? '',
      'city': city.trim(),
      'state': state?.trim() ?? '',
      'pincode': pincode?.trim() ?? '',
      'deliveryInstructions': deliveryInstructions?.trim() ?? '',
      'formattedAddress': deliveryAddress.trim(),
    };

    final orderData = {
      'orderId': orderId,
      'shopId': biz?.shopId ?? configuredShopId,
      'businessId': biz?.id ?? '',
      'businessName': biz?.name ?? 'Healthy Paws Pet Clinic',
      'userId': userId,
      'customerName': customerName.trim(),
      'customerPhone': customerPhone.trim(),
      'deliveryAddress': deliveryAddress.trim(),
      'city': city.trim(),
      if (houseOrFlat != null && houseOrFlat.trim().isNotEmpty) 'houseOrFlat': houseOrFlat.trim(),
      if (streetOrLocality != null && streetOrLocality.trim().isNotEmpty) 'streetOrLocality': streetOrLocality.trim(),
      if (landmark != null && landmark.trim().isNotEmpty) 'landmark': landmark.trim(),
      if (state != null && state.trim().isNotEmpty) 'state': state.trim(),
      if (pincode != null && pincode.trim().isNotEmpty) 'pincode': pincode.trim(),
      if (deliveryInstructions != null && deliveryInstructions.trim().isNotEmpty) 'deliveryInstructions': deliveryInstructions.trim(),
      'shippingAddress': addressSnapshot,
      'items': serializedItems,
      'itemCount': items.fold<int>(0, (totalCount, i) => totalCount + i.quantity),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'paymentStatus': 'Pending',
      'status': 'Placed',
      'orderStatus': 'Placed',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final docRef = await _firestore.collection('orders').add(orderData);
    // Also store doc id on the record
    await docRef.update({'id': docRef.id});
    return docRef.id;
  }
}
