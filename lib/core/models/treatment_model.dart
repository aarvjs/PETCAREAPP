import 'package:cloud_firestore/cloud_firestore.dart';

class TreatmentModel {
  final String id;
  final String petId;
  final String petName;
  final String registrationNumber;
  final String ownerId;
  final String businessId;
  final String shopId;
  final String medicineId;
  final String medicineName;
  final String medicineCategory;
  final double quantityUsed;
  final String unit;
  final String batchNumber;
  final String dosage;
  final DateTime administeredAt;
  final String administeredByName;
  final DateTime? nextDueDate;
  final String notes;
  final DateTime? createdAt;

  const TreatmentModel({
    required this.id,
    required this.petId,
    required this.petName,
    required this.registrationNumber,
    required this.ownerId,
    required this.businessId,
    required this.shopId,
    required this.medicineId,
    required this.medicineName,
    required this.medicineCategory,
    required this.quantityUsed,
    required this.unit,
    required this.batchNumber,
    required this.dosage,
    required this.administeredAt,
    required this.administeredByName,
    this.nextDueDate,
    required this.notes,
    this.createdAt,
  });

  factory TreatmentModel.fromFirestore(Map<String, dynamic> data, String docId) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is Timestamp) return val.toDate();
      if (val is String) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    DateTime? parseNullableDate(dynamic val) {
      if (val == null || (val is String && val.trim().isEmpty)) return null;
      if (val is Timestamp) return val.toDate();
      if (val is String) {
        return DateTime.tryParse(val);
      }
      return null;
    }

    double parseQty(dynamic val) {
      if (val == null) return 1.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 1.0;
      return 1.0;
    }

    return TreatmentModel(
      id: docId,
      petId: (data['petId'] ?? '').toString(),
      petName: (data['petName'] ?? '').toString(),
      registrationNumber: (data['registrationNumber'] ?? '').toString(),
      ownerId: (data['ownerId'] ?? '').toString(),
      businessId: (data['businessId'] ?? '').toString(),
      shopId: (data['shopId'] ?? '').toString(),
      medicineId: (data['medicineId'] ?? '').toString(),
      medicineName: (data['medicineName'] ?? 'Treatment').toString(),
      medicineCategory: (data['medicineCategory'] ?? 'Medicine').toString(),
      quantityUsed: parseQty(data['quantityUsed']),
      unit: (data['unit'] ?? 'unit').toString(),
      batchNumber: (data['batchNumber'] ?? '').toString(),
      dosage: (data['dosage'] ?? '').toString(),
      administeredAt: parseDate(data['administeredAt'] ?? data['createdAt']),
      administeredByName: (data['administeredByName'] ?? 'Doctor').toString(),
      nextDueDate: parseNullableDate(data['nextDueDate']),
      notes: (data['notes'] ?? '').toString(),
      createdAt: parseNullableDate(data['createdAt']),
    );
  }

  bool get isVaccine => medicineCategory.toLowerCase() == 'vaccine';

  bool get isUpcomingBooster {
    if (nextDueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return nextDueDate!.isAfter(today) || nextDueDate!.isAtSameMomentAs(today);
  }

  String get formattedAdminDate {
    return '${administeredAt.day.toString().padLeft(2, '0')}/${administeredAt.month.toString().padLeft(2, '0')}/${administeredAt.year}';
  }

  String? get formattedNextDueDate {
    if (nextDueDate == null) return null;
    return '${nextDueDate!.day.toString().padLeft(2, '0')}/${nextDueDate!.month.toString().padLeft(2, '0')}/${nextDueDate!.year}';
  }
}
