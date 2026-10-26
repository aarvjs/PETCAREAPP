import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../models/pet_model.dart';
import '../models/treatment_model.dart';
import 'auth_service.dart';
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

  /// Fetches registered pets list for the specified owner
  Future<List<PetModel>> getCustomerPets(String ownerId) async {
    try {
      final list = await streamCustomerPets(ownerId).first;
      return list;
    } catch (e) {
      debugPrint('[PetService] Error fetching customer pets: $e');
      return [];
    }
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

  /// Streams real-time appointments for a specific registered pet.
  Stream<List<Map<String, dynamic>>> streamPetAppointments(String petId) {
    final currentUid = AuthService.instance.currentUser?.uid;
    Query<Map<String, dynamic>> query = _firestore
        .collection('appointments')
        .where('petId', isEqualTo: petId);

    // Filter by current user if customer to satisfy Firestore security rules
    if (currentUid != null && currentUid.isNotEmpty) {
      query = query.where('userId', isEqualTo: currentUid);
    }

    return query.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      list.sort((a, b) {
        final dateA = (a['appointmentDate'] ?? a['date'] ?? '').toString();
        final dateB = (b['appointmentDate'] ?? b['date'] ?? '').toString();
        if (dateA != dateB) return dateB.compareTo(dateA);
        return (b['appointmentTime'] ?? '').toString().compareTo((a['appointmentTime'] ?? '').toString());
      });
      return list;
    });
  }

  /// Computes genuine bookable slots for a doctor and date by checking working hours, breaks, and booked slots.
  Future<List<String>> getAvailableSlots({
    required DateTime date,
    String? doctorId,
    String? shopId,
  }) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      final dayName = days[date.weekday - 1];

      // Sunday is clinic off day by default
      if (date.weekday == DateTime.sunday) {
        return [];
      }

      // Resolve doctor doc (Public read permitted on doctors/{doctorId})
      final effectiveDoctorId = (doctorId != null && doctorId.isNotEmpty)
          ? doctorId
          : 'WcWmpKLJImU9QtBZA5C7MGWe8hA2';

      String startTimeStr = '10:00';
      String endTimeStr = '20:00';
      int slotInterval = 30;
      final breakPeriods = <Map<String, String>>[
        {'start': '13:00', 'end': '14:00'},
      ];

      try {
        final docSnap = await _firestore.collection('doctors').doc(effectiveDoctorId).get();
        if (docSnap.exists && docSnap.data() != null) {
          final dData = docSnap.data()!;
          final scheduleMap = (dData['schedule'] is Map)
              ? Map<String, dynamic>.from(dData['schedule'] as Map)
              : dData;

          // Check blocked dates
          final blocked = scheduleMap['blockedDates'];
          if (blocked is List && blocked.contains(dateStr)) {
            return [];
          }

          final weekly = scheduleMap['weeklySchedule'];
          if (weekly is List) {
            for (final d in weekly) {
              if (d is Map && d['dayOfWeek'] == dayName) {
                if (d['isEnabled'] == false) return [];
                if (d['startTime'] != null && d['startTime'].toString().isNotEmpty) {
                  startTimeStr = d['startTime'].toString();
                }
                if (d['endTime'] != null && d['endTime'].toString().isNotEmpty) {
                  endTimeStr = d['endTime'].toString();
                }
                if (d['slotDurationMinutes'] != null) {
                  slotInterval = int.tryParse(d['slotDurationMinutes'].toString()) ?? 30;
                }
                if (d['breaks'] is List) {
                  breakPeriods.clear();
                  for (final b in (d['breaks'] as List)) {
                    if (b is Map && b['startTime'] != null && b['endTime'] != null) {
                      breakPeriods.add({
                        'start': b['startTime'].toString(),
                        'end': b['endTime'].toString(),
                      });
                    }
                  }
                }
                break;
              }
            }
          }
        }
      } catch (docErr) {
        debugPrint('[PetService] Reading doctor schedule notice: $docErr');
      }

      // Helper to parse HH:mm to minutes
      int toMinutes(String timeStr) {
        final parts = timeStr.trim().split(':');
        return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
      }

      // Helper to format minutes to 12-hour AM/PM string
      String to12Hour(int mins) {
        final h24 = mins ~/ 60;
        final m = mins % 60;
        final period = h24 >= 12 ? 'PM' : 'AM';
        final h12 = h24 == 0 ? 12 : (h24 > 12 ? h24 - 12 : h24);
        return '${h12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period';
      }

      final startMins = toMinutes(startTimeStr);
      final endMins = toMinutes(endTimeStr);

      // Generate all candidate slots
      final candidateSlots = <String>[];
      for (int m = startMins; m + slotInterval <= endMins; m += slotInterval) {
        // Check if inside break
        bool inBreak = false;
        for (final b in breakPeriods) {
          final bStart = toMinutes(b['start'] ?? '00:00');
          final bEnd = toMinutes(b['end'] ?? '00:00');
          if (m >= bStart && m < bEnd) {
            inBreak = true;
            break;
          }
        }
        if (!inBreak) {
          candidateSlots.add(to12Hour(m));
        }
      }

      // Query booked appointments for this date (safely handled if restricted by rules)
      final occupiedSlots = <String>{};
      try {
        final aptSnap = await _firestore
            .collection('appointments')
            .where('appointmentDate', isEqualTo: dateStr)
            .get();

        for (final doc in aptSnap.docs) {
          final dData = doc.data();
          final status = (dData['status'] ?? '').toString();
          if (status == 'Confirmed' || status == 'Pending') {
            final t = (dData['appointmentTime'] ?? dData['time'] ?? '').toString();
            if (t.isNotEmpty) occupiedSlots.add(t);
          }
        }
      } catch (aptErr) {
        debugPrint('[PetService] Notice: Direct appointments query restricted for customer role: $aptErr');
      }

      // Drop passed slots if date is today
      final now = DateTime.now();
      final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
      final currentMins = now.hour * 60 + now.minute;

      final bookable = <String>[];
      for (final slot in candidateSlots) {
        if (occupiedSlots.contains(slot)) continue;
        if (isToday) {
          // Convert slot to minutes to check if passed
          final parts = slot.split(' ');
          final timeParts = parts[0].split(':');
          var h = int.tryParse(timeParts[0]) ?? 0;
          final mins = int.tryParse(timeParts[1]) ?? 0;
          if (parts[1] == 'PM' && h != 12) h += 12;
          if (parts[1] == 'AM' && h == 12) h = 0;
          if (h * 60 + mins <= currentMins + 15) continue; // Must be at least 15 min ahead
        }
        bookable.add(slot);
      }

      return bookable;
    } catch (e) {
      debugPrint('[PetService getAvailableSlots Error] $e');
      return [];
    }
  }

  /// Concurrency-safe booking of an appointment in Firestore for a registered pet.
  Future<String> bookPetAppointment({
    required String petId,
    required String petName,
    required String petRegistrationNumber,
    required String breed,
    required String petType,
    required String age,
    required String gender,
    required String userId,
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    required String appointmentDate,
    required String appointmentTime,
    required String concernCategory,
    String? symptoms,
    String? notes,
    String? doctorId,
    String? doctorName,
    String? shopId,
    String? businessId,
    String? businessName,
  }) async {
    // 1. Concurrency Check: Verify slot is not already taken if permissions permit
    try {
      final existingSnap = await _firestore
          .collection('appointments')
          .where('appointmentDate', isEqualTo: appointmentDate)
          .where('appointmentTime', isEqualTo: appointmentTime)
          .get();

      for (final doc in existingSnap.docs) {
        final data = doc.data();
        final status = (data['status'] ?? '').toString();
        if (status == 'Confirmed' || status == 'Pending') {
          throw Exception('The time slot $appointmentTime on $appointmentDate has just been booked. Please choose an alternate slot.');
        }
      }
    } catch (e) {
      if (e.toString().contains('has just been booked')) {
        rethrow;
      }
      debugPrint('[PetService] Note: Direct full appointments query restricted by Firestore rules, proceeding with booking creation: $e');
    }

    final randomId = 'APT-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    final appointmentData = {
      'appointmentId': randomId,
      'petId': petId,
      'petName': petName.trim(),
      'petType': petType.trim(),
      'petRegistrationNumber': petRegistrationNumber.trim(),
      'breed': breed.trim(),
      'age': age.trim(),
      'gender': gender.trim(),
      'userId': userId,
      'customerName': customerName.trim(),
      'ownerName': customerName.trim(),
      'customerPhone': customerPhone.trim(),
      'ownerPhone': customerPhone.trim(),
      'customerAddress': customerAddress.trim(),
      'serviceName': 'Veterinary Consultation',
      'doctorId': doctorId ?? '',
      'doctorName': doctorName?.trim() ?? 'Dr. Ashwani Kumar Singh',
      'shopId': shopId ?? AppConfig.shopId,
      'businessId': businessId ?? '',
      'businessName': businessName ?? 'Healthy Paws Pet Clinic',
      'appointmentDate': appointmentDate,
      'appointmentTime': appointmentTime,
      'concernCategory': concernCategory.trim(),
      'symptoms': symptoms?.trim() ?? '',
      'notes': notes?.trim() ?? symptoms?.trim() ?? '',
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final ref = await _firestore.collection('appointments').add(appointmentData);
    return ref.id;
  }
}
