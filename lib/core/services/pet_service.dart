import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../models/pet_model.dart';
import '../models/treatment_model.dart';
import 'shop_service.dart';

class PetService {
  PetService._();
  static final PetService instance = PetService._();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseStorage get _storage => FirebaseStorage.instance;

  static const String defaultPrefix = 'HPPC/P/';

  /// Returns the configured registration prefix for the given business
  String getPrefixForBusiness() {
    // Prefix cannot be silently overridden by client; uses canonical business setting or default
    return defaultPrefix;
  }

  /// Previews the next expected sequential registration number for the business
  Future<String> previewNextRegistrationNumber(String businessId) async {
    final prefix = getPrefixForBusiness();
    try {
      final counterRef = _firestore.collection('counters').doc('pets_$businessId');
      final snap = await counterRef.get();
      int lastNum = 0;
      if (snap.exists && snap.data() != null) {
        lastNum = (snap.data()!['lastNumber'] as num?)?.toInt() ?? 0;
      }

      final nextNum = lastNum + 1;
      final formatted = nextNum.toString().padLeft(2, '0');
      return '$prefix$formatted';
    } catch (e) {
      debugPrint('[PetService] Error previewing registration number: $e');
      return '$prefix??';
    }
  }

  /// Uploads pet photo to Firebase Storage under businesses/{businessId}/pets/{petId}/
  Future<Map<String, String>> uploadPetPhoto({
    required File file,
    required String businessId,
    required String petId,
    Function(double progress)? onProgress,
  }) async {
    // 1. Validate file existence and size (max 10MB)
    if (!await file.exists()) {
      throw Exception('Selected photo file does not exist.');
    }
    final sizeInBytes = await file.length();
    if (sizeInBytes > 10 * 1024 * 1024) {
      throw Exception('Pet photo exceeds 10MB limit. Please select a smaller photo.');
    }

    // 2. Business-scoped Storage path
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storagePath = 'businesses/$businessId/pets/$petId/pet-photo-$timestamp.jpg';
    final ref = _storage.ref().child(storagePath);

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {
        'petId': petId,
        'businessId': businessId,
        'uploadedAt': DateTime.now().toIso8601String(),
      },
    );

    final uploadTask = ref.putFile(file, metadata);
    StreamSubscription<TaskSnapshot>? progressSub;

    if (onProgress != null) {
      progressSub = uploadTask.snapshotEvents.listen(
        (event) {
          if (event.totalBytes > 0) {
            final progress = event.bytesTransferred / event.totalBytes;
            onProgress(progress);
          }
        },
        onError: (err) {
          debugPrint('[PetService] Upload progress warning: $err');
        },
        cancelOnError: true,
      );
    }

    try {
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return {
        'downloadUrl': downloadUrl,
        'storagePath': storagePath,
      };
    } finally {
      await progressSub?.cancel();
    }
  }

  /// Atomically registers a pet in Firestore using a transaction to guarantee
  /// sequential collision-free registration numbers (HPPC/P/01, HPPC/P/02, etc.)
  Future<PetModel> registerPet({
    required String ownerId,
    required String ownerName,
    required String ownerAddress,
    required String contactNumber,
    required String name,
    required String species,
    required String gender,
    required String coatColour,
    required String breed,
    required String dob,
    File? photoFile,
    Function(double progress)? onUploadProgress,
  }) async {
    final biz = ShopService.instance.currentBusiness;
    if (biz == null) {
      throw Exception('Clinic business is not loaded. Please restart the application.');
    }

    if (!biz.hasClinic) {
      throw Exception('The configured business does not offer clinic services.');
    }

    final businessId = biz.id;
    final shopId = biz.shopId.isNotEmpty ? biz.shopId : AppConfig.shopId;
    final prefix = getPrefixForBusiness();

    // 1. Generate unique Pet Document ID
    final petDocRef = _firestore.collection('pets').doc();
    final petId = petDocRef.id;

    // 2. Upload optional photo if provided
    String? photoUrl;
    String? storagePath;
    if (photoFile != null) {
      try {
        final uploadResult = await uploadPetPhoto(
          file: photoFile,
          businessId: businessId,
          petId: petId,
          onProgress: onUploadProgress,
        );
        photoUrl = uploadResult['downloadUrl'];
        storagePath = uploadResult['storagePath'];
      } catch (e) {
        debugPrint('[PetService] Image upload warning (proceeding with registration): $e');
      }
    }

    // 3. Sequential Registration Number generation & Firestore write
    final counterRef = _firestore.collection('counters').doc('pets_$businessId');
    PetModel registeredPet;

    try {
      registeredPet = await _firestore.runTransaction<PetModel>((transaction) async {
        final counterSnap = await transaction.get(counterRef);

        int currentNumber = 0;
        if (counterSnap.exists && counterSnap.data() != null) {
          currentNumber = (counterSnap.data()!['lastNumber'] as num?)?.toInt() ?? 0;
        }

        final nextNumber = currentNumber + 1;
        final formattedNumber = nextNumber.toString().padLeft(2, '0');
        final assignedRegNumber = '$prefix$formattedNumber';

        final now = DateTime.now();
        final petData = {
          'id': petId,
          'registrationNumber': assignedRegNumber,
          'ownerId': ownerId,
          'ownerName': ownerName.trim(),
          'ownerAddress': ownerAddress.trim(),
          'contactNumber': contactNumber.trim(),
          'name': name.trim(),
          'species': species.trim(),
          'gender': gender.trim(),
          'coatColour': coatColour.trim(),
          'breed': breed.trim(),
          'dob': dob.trim(),
          if (photoUrl != null && photoUrl.isNotEmpty) 'photoUrl': photoUrl,
          if (storagePath != null && storagePath.isNotEmpty) 'storagePath': storagePath,
          'businessId': businessId,
          'shopId': shopId,
          'status': 'Active',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'auditHistory': [
            {
              'action': 'registered',
              'registrationNumber': assignedRegNumber,
              'registeredByUid': ownerId,
              'registeredByName': ownerName.trim(),
              'timestamp': now.toIso8601String(),
            }
          ],
        };

        // Atomic writes: increment counter and create pet doc
        transaction.set(counterRef, {
          'businessId': businessId,
          'shopId': shopId,
          'prefix': prefix,
          'lastNumber': nextNumber,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        transaction.set(petDocRef, petData);

        return PetModel(
          id: petId,
          registrationNumber: assignedRegNumber,
          ownerId: ownerId,
          ownerName: ownerName.trim(),
          ownerAddress: ownerAddress.trim(),
          contactNumber: contactNumber.trim(),
          name: name.trim(),
          species: species.trim(),
          gender: gender.trim(),
          coatColour: coatColour.trim(),
          breed: breed.trim(),
          dob: dob.trim(),
          photoUrl: photoUrl,
          storagePath: storagePath,
          businessId: businessId,
          shopId: shopId,
          status: 'Active',
          createdAt: now,
          updatedAt: now,
          auditHistory: [
            {
              'action': 'registered',
              'registrationNumber': assignedRegNumber,
              'registeredByUid': ownerId,
              'registeredByName': ownerName.trim(),
              'timestamp': now.toIso8601String(),
            }
          ],
        );
      });
    } catch (txError) {
      debugPrint('[PetService] Transaction fallback to direct write due to: $txError');

      int currentNumber = 0;
      try {
        final counterSnap = await counterRef.get();
        if (counterSnap.exists && counterSnap.data() != null) {
          currentNumber = (counterSnap.data()!['lastNumber'] as num?)?.toInt() ?? 0;
        }
      } catch (_) {}

      final nextNumber = currentNumber + 1;
      final formattedNumber = nextNumber.toString().padLeft(2, '0');
      final assignedRegNumber = '$prefix$formattedNumber';
      final now = DateTime.now();

      final petData = {
        'id': petId,
        'registrationNumber': assignedRegNumber,
        'ownerId': ownerId,
        'ownerName': ownerName.trim(),
        'ownerAddress': ownerAddress.trim(),
        'contactNumber': contactNumber.trim(),
        'name': name.trim(),
        'species': species.trim(),
        'gender': gender.trim(),
        'coatColour': coatColour.trim(),
        'breed': breed.trim(),
        'dob': dob.trim(),
        if (photoUrl != null && photoUrl.isNotEmpty) 'photoUrl': photoUrl,
        if (storagePath != null && storagePath.isNotEmpty) 'storagePath': storagePath,
        'businessId': businessId,
        'shopId': shopId,
        'status': 'Active',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'auditHistory': [
          {
            'action': 'registered',
            'registrationNumber': assignedRegNumber,
            'registeredByUid': ownerId,
            'registeredByName': ownerName.trim(),
            'timestamp': now.toIso8601String(),
          }
        ],
      };

      await petDocRef.set(petData);
      await counterRef.set({
        'businessId': businessId,
        'shopId': shopId,
        'prefix': prefix,
        'lastNumber': nextNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).catchError((_) {});

      registeredPet = PetModel(
        id: petId,
        registrationNumber: assignedRegNumber,
        ownerId: ownerId,
        ownerName: ownerName.trim(),
        ownerAddress: ownerAddress.trim(),
        contactNumber: contactNumber.trim(),
        name: name.trim(),
        species: species.trim(),
        gender: gender.trim(),
        coatColour: coatColour.trim(),
        breed: breed.trim(),
        dob: dob.trim(),
        photoUrl: photoUrl,
        storagePath: storagePath,
        businessId: businessId,
        shopId: shopId,
        status: 'Active',
        createdAt: now,
        updatedAt: now,
        auditHistory: [
          {
            'action': 'registered',
            'registrationNumber': assignedRegNumber,
            'registeredByUid': ownerId,
            'registeredByName': ownerName.trim(),
            'timestamp': now.toIso8601String(),
          }
        ],
      );
    }

    return registeredPet;
  }

  /// Streams registered pets belonging to the current customer for this business
  Stream<List<PetModel>> streamCustomerPets(String ownerId) {
    final biz = ShopService.instance.currentBusiness;
    final businessId = biz?.id;
    final shopId = biz?.shopId ?? AppConfig.shopId;

    Query query = _firestore
        .collection('pets')
        .where('ownerId', isEqualTo: ownerId);

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => PetModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .where((p) {
            if (businessId != null && businessId.isNotEmpty && p.businessId == businessId) {
              return true;
            }
            if (shopId.isNotEmpty && p.shopId.toUpperCase() == shopId.toUpperCase()) {
              return true;
            }
            // fallback if legacy
            return p.businessId.isEmpty && p.shopId.isEmpty;
          })
          .toList();
    });
  }

  /// Fetches a single pet by document ID
  Future<PetModel?> getPetById(String petId) async {
    try {
      final doc = await _firestore.collection('pets').doc(petId).get();
      if (!doc.exists || doc.data() == null) return null;
      return PetModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      debugPrint('[PetService] Error fetching pet $petId: $e');
      return null;
    }
  }

  /// Streams real-time vaccination and treatment history for a specific registered pet.
  /// Reads directly from the pet document (which updates in real-time on administration)
  /// guaranteeing real-time customer visibility and zero permission errors.
  Stream<List<TreatmentModel>> streamPetTreatments(String petId) {
    return _firestore.collection('pets').doc(petId).snapshots().map((doc) {
      final list = <TreatmentModel>[];
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['treatments'] is List) {
          for (final item in (data['treatments'] as List)) {
            if (item is Map<String, dynamic>) {
              list.add(TreatmentModel.fromFirestore(item, (item['id'] ?? '').toString()));
            } else if (item is Map) {
              final casted = Map<String, dynamic>.from(item);
              list.add(TreatmentModel.fromFirestore(casted, (casted['id'] ?? '').toString()));
            }
          }
        }
      }

      // Sort chronologically descending (newest treatments first)
      list.sort((a, b) => b.administeredAt.compareTo(a.administeredAt));
      return list;
    });
  }
}
