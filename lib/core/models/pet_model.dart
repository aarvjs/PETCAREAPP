import 'package:cloud_firestore/cloud_firestore.dart';

class PetModel {
  final String id;
  final String registrationNumber;
  final String ownerId;
  final String ownerName;
  final String ownerAddress;
  final String contactNumber;
  final String name;
  final String species;
  final String gender;
  final String coatColour;
  final String breed;
  final String dob;
  final String? photoUrl;
  final String? storagePath;
  final String businessId;
  final String shopId;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? medicalNotes;
  final String? lastVisit;
  final List<Map<String, dynamic>> auditHistory;

  const PetModel({
    required this.id,
    required this.registrationNumber,
    required this.ownerId,
    required this.ownerName,
    required this.ownerAddress,
    required this.contactNumber,
    required this.name,
    required this.species,
    required this.gender,
    required this.coatColour,
    required this.breed,
    required this.dob,
    this.photoUrl,
    this.storagePath,
    required this.businessId,
    required this.shopId,
    this.status = 'Active',
    this.createdAt,
    this.updatedAt,
    this.medicalNotes,
    this.lastVisit,
    this.auditHistory = const [],
  });

  /// Calculates human-friendly age from DOB string (supports YYYY-MM-DD or ISO)
  String get ageDisplay {
    if (dob.isEmpty) return 'Age Unknown';
    try {
      final birthDate = DateTime.tryParse(dob);
      if (birthDate == null) return dob;
      final now = DateTime.now();
      int years = now.year - birthDate.year;
      int months = now.month - birthDate.month;
      if (now.day < birthDate.day) {
        months--;
      }
      if (months < 0) {
        years--;
        months += 12;
      }
      if (years <= 0 && months <= 0) {
        final days = now.difference(birthDate).inDays;
        return '$days days';
      }
      if (years <= 0) {
        return '$months ${months == 1 ? "month" : "months"}';
      }
      if (months == 0) {
        return '$years ${years == 1 ? "yr" : "yrs"}';
      }
      return '$years ${years == 1 ? "yr" : "yrs"} $months m';
    } catch (_) {
      return dob;
    }
  }

  factory PetModel.fromFirestore(Map<String, dynamic> data, String docId) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    final rawHistory = data['auditHistory'];
    List<Map<String, dynamic>> parsedHistory = [];
    if (rawHistory is List) {
      parsedHistory = rawHistory
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    return PetModel(
      id: docId,
      registrationNumber: data['registrationNumber'] ?? data['regNo'] ?? '',
      ownerId: data['ownerId'] ?? data['userId'] ?? '',
      ownerName: data['ownerName'] ?? data['customerName'] ?? '',
      ownerAddress: data['ownerAddress'] ?? data['address'] ?? '',
      contactNumber: data['contactNumber'] ?? data['ownerPhone'] ?? data['phone'] ?? '',
      name: data['name'] ?? data['petName'] ?? '',
      species: data['species'] ?? data['type'] ?? data['petType'] ?? 'Dog',
      gender: data['gender'] ?? 'Male',
      coatColour: data['coatColour'] ?? data['coatColor'] ?? '',
      breed: data['breed'] ?? '',
      dob: data['dob'] ?? data['dateOfBirth'] ?? '',
      photoUrl: data['photoUrl'] ?? data['photo'] ?? data['image'],
      storagePath: data['storagePath'],
      businessId: data['businessId'] ?? '',
      shopId: data['shopId'] ?? '',
      status: data['status'] ?? 'Active',
      createdAt: parseDate(data['createdAt']),
      updatedAt: parseDate(data['updatedAt']),
      medicalNotes: data['medicalNotes'],
      lastVisit: data['lastVisit'],
      auditHistory: parsedHistory,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'registrationNumber': registrationNumber,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerAddress': ownerAddress,
      'contactNumber': contactNumber,
      'name': name,
      'species': species,
      'gender': gender,
      'coatColour': coatColour,
      'breed': breed,
      'dob': dob,
      if (photoUrl != null && photoUrl!.isNotEmpty) 'photoUrl': photoUrl,
      if (storagePath != null && storagePath!.isNotEmpty) 'storagePath': storagePath,
      'businessId': businessId,
      'shopId': shopId,
      'status': status,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (medicalNotes != null) 'medicalNotes': medicalNotes,
      if (lastVisit != null) 'lastVisit': lastVisit,
      'auditHistory': auditHistory,
    };
  }

  PetModel copyWith({
    String? registrationNumber,
    String? ownerName,
    String? ownerAddress,
    String? contactNumber,
    String? name,
    String? species,
    String? gender,
    String? coatColour,
    String? breed,
    String? dob,
    String? photoUrl,
    String? storagePath,
    String? status,
    String? medicalNotes,
    String? lastVisit,
    List<Map<String, dynamic>>? auditHistory,
  }) {
    return PetModel(
      id: id,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      ownerId: ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerAddress: ownerAddress ?? this.ownerAddress,
      contactNumber: contactNumber ?? this.contactNumber,
      name: name ?? this.name,
      species: species ?? this.species,
      gender: gender ?? this.gender,
      coatColour: coatColour ?? this.coatColour,
      breed: breed ?? this.breed,
      dob: dob ?? this.dob,
      photoUrl: photoUrl ?? this.photoUrl,
      storagePath: storagePath ?? this.storagePath,
      businessId: businessId,
      shopId: shopId,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      medicalNotes: medicalNotes ?? this.medicalNotes,
      lastVisit: lastVisit ?? this.lastVisit,
      auditHistory: auditHistory ?? this.auditHistory,
    );
  }
}
