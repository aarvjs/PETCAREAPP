/// The specific customer experience configured for the active business
enum AppExperience {
  /// Store only: products, categories, search, cart, checkout, orders
  ecommerceOnly,

  /// Clinic only: dedicated veterinary care, doctor profiles, appointments, timings
  clinicOnly,

  /// Combined: unified pet shop and clinic healthcare
  combined,

  /// Clinic module is enabled on the business, but content/services are not yet published
  clinicPendingSetup,

  /// Business is inactive or unavailable
  unavailable,
}

class BusinessModel {
  final String id;
  final String shopId;
  final String name;
  final String businessType;
  final String? logoUrl;
  final String? phone;
  final String? email;
  final String? address;
  final String? city;
  final String? state;
  final String status;
  final List<String> modules;
  final bool clinicPublished;
  final bool ecommercePublished;
  final String clinicTimings;
  final String? emergencyPhone;

  const BusinessModel({
    required this.id,
    required this.shopId,
    required this.name,
    this.businessType = 'Pet Clinic & Store',
    this.logoUrl,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.state,
    this.status = 'active',
    this.modules = const ['ecommerce', 'clinic'],
    this.clinicPublished = true,
    this.ecommercePublished = true,
    this.clinicTimings = 'Mon - Sat: 09:00 AM - 08:00 PM',
    this.emergencyPhone,
  });

  bool get isActive => status.toLowerCase() == 'active';

  /// Whether the business offers online pet product sales
  bool get hasEcommerce =>
      modules.contains('ecommerce') || modules.contains('store');

  /// Whether the business offers veterinary / clinic / doctor services
  bool get hasClinic =>
      modules.contains('clinic') || modules.contains('doctor') || modules.contains('hospital');

  /// Whether clinic module is fully configured and published for customers
  bool get isClinicReady => hasClinic && clinicPublished;

  /// Whether ecommerce module is fully configured and published for customers
  bool get isEcommerceReady => hasEcommerce && ecommercePublished;

  /// Resolves the intended customer app experience
  AppExperience get experience {
    if (!isActive) return AppExperience.unavailable;

    if (hasEcommerce && hasClinic) {
      // If both enabled, but clinic is not yet published, keep smooth ecommerce visible
      return clinicPublished ? AppExperience.combined : AppExperience.ecommerceOnly;
    }

    if (hasEcommerce && !hasClinic) {
      return AppExperience.ecommerceOnly;
    }

    if (hasClinic && !hasEcommerce) {
      return clinicPublished ? AppExperience.clinicOnly : AppExperience.clinicPendingSetup;
    }

    // Default fallback to ecommerce if modules list is empty
    return AppExperience.ecommerceOnly;
  }

  factory BusinessModel.fromFirestore(Map<String, dynamic> data, String docId) {
    List<String> parsedModules = [];

    // 1. Direct modules array
    if (data['modules'] is List) {
      parsedModules = (data['modules'] as List).map((e) => e.toString().toLowerCase()).toList();
    }

    // 2. Fallback to assignedAdmins module list
    if (parsedModules.isEmpty && data['assignedAdmins'] is List) {
      for (final admin in data['assignedAdmins'] as List) {
        if (admin is Map && admin['modules'] is List) {
          parsedModules.addAll(
            (admin['modules'] as List).map((e) => e.toString().toLowerCase()),
          );
        }
      }
    }

    // Default to both if not specified in Firestore
    if (parsedModules.isEmpty) {
      parsedModules = ['ecommerce', 'clinic'];
    }

    // Publication state evaluation:
    // If clinicStatus == 'draft' or clinicPublished == false, clinic is not published
    final clinicStatus = (data['clinicStatus'] ?? '').toString().toLowerCase();
    final bool isClinicPub = data['clinicPublished'] != false && clinicStatus != 'draft';

    final ecommerceStatus = (data['ecommerceStatus'] ?? '').toString().toLowerCase();
    final bool isEcomPub = data['ecommercePublished'] != false && ecommerceStatus != 'draft';

    return BusinessModel(
      id: docId,
      shopId: data['shopId'] ?? '',
      name: data['name'] ?? 'Healthy Paws Pet Clinic',
      businessType: data['businessType'] ?? 'Pet Clinic & Hospital',
      logoUrl: data['logoUrl'] ?? data['logo'],
      phone: data['phone'],
      email: data['email'],
      address: data['address'],
      city: data['city'],
      state: data['state'],
      status: data['status'] ?? 'active',
      modules: parsedModules.toSet().toList(),
      clinicPublished: isClinicPub,
      ecommercePublished: isEcomPub,
      clinicTimings: data['clinicTimings'] ?? 'Mon - Sat: 09:00 AM - 08:00 PM',
      emergencyPhone: data['emergencyPhone'] ?? data['phone'],
    );
  }

  factory BusinessModel.fallback({required String shopId}) {
    return BusinessModel(
      id: 'biz_default',
      shopId: shopId,
      name: 'Healthy Paws Pet Clinic',
      businessType: 'Pet Clinic & Store',
      city: 'Kanpur',
      state: 'Uttar Pradesh',
      modules: const ['ecommerce', 'clinic'],
      clinicPublished: true,
      ecommercePublished: true,
    );
  }
}
