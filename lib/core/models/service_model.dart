import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String duration;
  final String image;
  final String? storagePath;
  final String status;
  final String businessId;
  final String shopId;
  final dynamic createdAt;
  final dynamic updatedAt;

  const ServiceModel({
    required this.id,
    required this.name,
    this.description = '',
    this.category = 'Consultation',
    this.price = 0.0,
    this.duration = '30 mins',
    this.image = '',
    this.storagePath,
    this.status = 'Active',
    this.businessId = '',
    this.shopId = '',
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status.toLowerCase() == 'active';

  String get formattedPrice {
    if (price <= 0) return 'Free / Quote';
    if (price % 1 == 0) {
      return '₹${price.toInt()}';
    }
    return '₹${price.toStringAsFixed(2)}';
  }

  factory ServiceModel.fromFirestore(Map<String, dynamic> data, String docId) {
    double parsedPrice = 0.0;
    final rawPrice = data['price'];
    if (rawPrice is num) {
      parsedPrice = rawPrice.toDouble();
    } else if (rawPrice is String) {
      parsedPrice = double.tryParse(rawPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    }

    return ServiceModel(
      id: docId,
      name: (data['name'] ?? data['title'] ?? 'Veterinary Service').toString().trim(),
      description: (data['description'] ?? '').toString().trim(),
      category: (data['category'] ?? 'General Care').toString().trim(),
      price: parsedPrice,
      duration: (data['duration'] ?? '30 mins').toString().trim(),
      image: (data['image'] ?? data['imageUrl'] ?? data['photoUrl'] ?? '').toString().trim(),
      storagePath: data['storagePath'] as String?,
      status: (data['status'] ?? 'Active').toString().trim(),
      businessId: (data['businessId'] ?? '').toString().trim(),
      shopId: (data['shopId'] ?? '').toString().trim(),
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'duration': duration,
      'image': image,
      if (storagePath != null) 'storagePath': storagePath,
      'status': status,
      'businessId': businessId,
      'shopId': shopId,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
