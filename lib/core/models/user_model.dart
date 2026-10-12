import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String phoneNumber;
  final String? name;
  final String? email;
  final String? profileImage;
  final String? city;
  final String? address;
  final int? petCount;
  final String role;
  final bool profileCompleted;
  final bool profileSkipped;
  final dynamic createdAt;
  final dynamic updatedAt;

  UserModel({
    required this.uid,
    required this.phoneNumber,
    this.name,
    this.email,
    this.profileImage,
    this.city,
    this.address,
    this.petCount,
    this.role = 'customer',
    this.profileCompleted = false,
    this.profileSkipped = false,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      uid: map['uid'] ?? docId,
      phoneNumber: map['phoneNumber'] ?? map['phone'] ?? '',
      name: map['name'] ?? map['fullName'],
      email: map['email'],
      profileImage: map['profileImage'] ?? map['photoURL'],
      city: map['city'],
      address: map['address'],
      petCount: map['petCount'] is int ? map['petCount'] as int : null,
      role: map['role'] ?? 'customer',
      profileCompleted: map['profileCompleted'] ?? false,
      profileSkipped: map['profileSkipped'] ?? false,
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'role': role,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (profileImage != null) 'profileImage': profileImage,
      if (city != null) 'city': city,
      if (address != null) 'address': address,
      if (petCount != null) 'petCount': petCount,
      'profileCompleted': profileCompleted,
      'profileSkipped': profileSkipped,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? phoneNumber,
    String? name,
    String? email,
    String? profileImage,
    String? city,
    String? address,
    int? petCount,
    String? role,
    bool? profileCompleted,
    bool? profileSkipped,
    dynamic createdAt,
    dynamic updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      city: city ?? this.city,
      address: address ?? this.address,
      petCount: petCount ?? this.petCount,
      role: role ?? this.role,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      profileSkipped: profileSkipped ?? this.profileSkipped,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

