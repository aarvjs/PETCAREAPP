import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'pet_service.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  UserModel? _currentUserProfile;
  UserModel? get currentUserProfile => _cachedProfile;
  UserModel? get _cachedProfile => _currentUserProfile;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Formats Indian mobile numbers to standard +91XXXXXXXXXX format
  String formatPhoneNumber(String phone) {
    final cleanDigits = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanDigits.startsWith('91') && cleanDigits.length == 12) {
      return '+$cleanDigits';
    }
    if (cleanDigits.length == 11 && cleanDigits.startsWith('0')) {
      return '+91${cleanDigits.substring(1)}';
    }
    if (cleanDigits.length == 10) {
      return '+91$cleanDigits';
    }
    if (phone.startsWith('+')) {
      return phone;
    }
    return '+91$cleanDigits';
  }

  /// Returns masked mobile number for security (e.g. +91 98****3210)
  String maskPhoneNumber(String phone) {
    final clean = formatPhoneNumber(phone);
    if (clean.length >= 13) {
      final country = clean.substring(0, 3);
      final firstTwo = clean.substring(3, 5);
      final lastFour = clean.substring(clean.length - 4);
      return '$country $firstTwo****$lastFour';
    }
    if (clean.length >= 10) {
      final firstTwo = clean.substring(0, 2);
      final lastFour = clean.substring(clean.length - 4);
      return '+91 $firstTwo****$lastFour';
    }
    return clean;
  }

  /// Checks if a role is a clinic staff / admin role
  bool isPrivilegedRole(String? role) {
    if (role == null) return false;
    final r = role.toLowerCase().trim();
    return r == 'admin' ||
        r == 'doctor' ||
        r == 'super_admin' ||
        r == 'business' ||
        r == 'business_tenant';
  }

  /// Trigger Firebase Phone Auth OTP sending
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(String errorMessage) onError,
    required Function(PhoneAuthCredential credential) onAutoVerified,
    int? resendToken,
  }) async {
    final formattedPhone = formatPhoneNumber(phoneNumber);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        forceResendingToken: resendToken,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);
            onAutoVerified(credential);
          } catch (e) {
            onError(getFriendlyErrorMessage(e));
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(getFriendlyErrorMessage(e));
        },
        codeSent: (String verificationId, int? newResendToken) {
          onCodeSent(verificationId, newResendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto retrieval timeout reached
        },
      );
    } catch (e) {
      onError(getFriendlyErrorMessage(e));
    }
  }

  /// Verify entered OTP SMS code with Firebase Auth
  Future<UserCredential> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode.trim(),
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw getFriendlyErrorMessage(e);
    }
  }

  /// Fetches user profile document from Firestore (`users/{uid}`)
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        _currentUserProfile = UserModel.fromMap(doc.data()!, doc.id);
        return _currentUserProfile;
      }
      return _currentUserProfile;
    } catch (e) {
      return _currentUserProfile;
    }
  }

  /// Updates profile in memory cache immediately
  void updateLocalProfile({
    String? name,
    String? email,
    String? city,
    String? address,
    String? profileImage,
    int? petCount,
    bool? profileCompleted,
    bool? profileSkipped,
  }) {
    String uid = _currentUserProfile?.uid ?? '';
    String phone = _currentUserProfile?.phoneNumber ?? '';
    try {
      uid = uid.isNotEmpty ? uid : (_auth.currentUser?.uid ?? '');
      phone = phone.isNotEmpty ? phone : (_auth.currentUser?.phoneNumber ?? '');
    } catch (_) {}

    _currentUserProfile = (_currentUserProfile ?? UserModel(
      uid: uid,
      phoneNumber: phone,
      role: 'customer',
    )).copyWith(
      name: name != null && name.trim().isNotEmpty ? name.trim() : _currentUserProfile?.name,
      email: email != null && email.trim().isNotEmpty ? email.trim() : _currentUserProfile?.email,
      city: city != null && city.trim().isNotEmpty ? city.trim() : _currentUserProfile?.city,
      address: address != null && address.trim().isNotEmpty ? address.trim() : _currentUserProfile?.address,
      profileImage: profileImage ?? _currentUserProfile?.profileImage,
      petCount: petCount ?? _currentUserProfile?.petCount,
      profileCompleted: profileCompleted ?? _currentUserProfile?.profileCompleted ?? false,
      profileSkipped: profileSkipped ?? _currentUserProfile?.profileSkipped ?? false,
    );
  }

  /// Ensures a minimum customer user document exists in Firestore upon authentication.
  /// Prevents overwriting or escalating privileged roles (admin, doctor, super_admin).
  Future<UserModel> createOrEnsureMinProfile(String uid, String phoneNumber) async {
    final formattedPhone = formatPhoneNumber(phoneNumber);
    try {
      final docRef = _firestore.collection('users').doc(uid);
      final snapshot = await docRef.get();

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        final existingRole = data['role']?.toString();

        if (isPrivilegedRole(existingRole)) {
          await _auth.signOut();
          throw 'This account is registered as Clinic Staff / Administrator ($existingRole). Please use the Admin Portal to sign in.';
        }

        final profile = UserModel.fromMap(data, snapshot.id);
        _currentUserProfile = profile;

        // Securely claim any offline walk-in records for this verified phone number
        PetService.instance.claimOfflinePatientRecords(
          uid: uid,
          phoneNumber: formattedPhone,
        );

        return profile;
      } else {
        final initialData = {
          'uid': uid,
          'phoneNumber': formattedPhone,
          'role': 'customer',
          'profileCompleted': false,
          'profileSkipped': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        await docRef.set(initialData, SetOptions(merge: true));
        final profile = UserModel(
          uid: uid,
          phoneNumber: formattedPhone,
          role: 'customer',
          profileCompleted: false,
          profileSkipped: false,
        );
        _currentUserProfile = profile;

        // Securely claim any offline walk-in records for this verified phone number
        PetService.instance.claimOfflinePatientRecords(
          uid: uid,
          phoneNumber: formattedPhone,
        );

        return profile;
      }
    } catch (e) {
      if (e.toString().contains('Clinic Staff')) rethrow;
      // Provide fallback customer profile so user is not blocked
      final fallback = UserModel(
        uid: uid,
        phoneNumber: formattedPhone,
        role: 'customer',
        profileCompleted: false,
        profileSkipped: false,
      );
      _currentUserProfile = fallback;
      return fallback;
    }
  }

  /// Save / update customer user profile in Firestore.
  /// Strictly prevents updating role or administrative fields.
  Future<void> updateProfile({
    required String uid,
    String? name,
    String? email,
    String? city,
    String? address,
    String? profileImage,
    int? petCount,
    bool profileCompleted = true,
    bool profileSkipped = false,
  }) async {
    // 1. Update in-memory session profile immediately
    updateLocalProfile(
      name: name,
      email: email,
      city: city,
      address: address,
      profileImage: profileImage,
      petCount: petCount,
      profileCompleted: profileCompleted,
      profileSkipped: profileSkipped,
    );

    // 2. Persist to Firestore
    final docRef = _firestore.collection('users').doc(uid);
    DocumentSnapshot<Map<String, dynamic>>? snapshot;
    try {
      snapshot = await docRef.get();
    } catch (_) {}

    if (snapshot != null && snapshot.exists && snapshot.data() != null) {
      final existingRole = snapshot.data()!['role']?.toString();
      if (isPrivilegedRole(existingRole)) {
        await _auth.signOut();
        throw 'Modification of administrative profiles is not permitted from the customer application.';
      }
    }

    final updateData = <String, dynamic>{
      'profileCompleted': profileCompleted,
      'profileSkipped': profileSkipped,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (name != null) updateData['name'] = name.trim();
    if (email != null) updateData['email'] = email.trim();
    if (city != null) updateData['city'] = city.trim();
    if (address != null) updateData['address'] = address.trim();
    if (profileImage != null) updateData['profileImage'] = profileImage;
    if (petCount != null) updateData['petCount'] = petCount;

    if (snapshot != null && snapshot.exists) {
      try {
        await docRef.update(updateData);
      } catch (_) {
        await docRef.set(updateData, SetOptions(merge: true));
      }
    } else {
      updateData['uid'] = uid;
      updateData['phoneNumber'] = _currentUserProfile?.phoneNumber ?? _auth.currentUser?.phoneNumber ?? '';
      updateData['role'] = 'customer';
      updateData['createdAt'] = FieldValue.serverTimestamp();
      await docRef.set(updateData, SetOptions(merge: true));
    }
  }

  /// User skipped profile setup
  Future<void> skipProfile(String uid) async {
    // 1. Immediately cache skipped status in memory
    updateLocalProfile(
      profileCompleted: false,
      profileSkipped: true,
    );

    // 2. Best-effort write to Firestore (never blocks user)
    try {
      final docRef = _firestore.collection('users').doc(uid);
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        await docRef.update({
          'profileCompleted': false,
          'profileSkipped': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.set({
          'uid': uid,
          'phoneNumber': _currentUserProfile?.phoneNumber ?? _auth.currentUser?.phoneNumber ?? '',
          'role': 'customer',
          'profileCompleted': false,
          'profileSkipped': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (_) {
      // Background persistence failure does not block the customer from shopping
    }
  }

  /// Logout user completely from Firebase Auth
  Future<void> signOut() async {
    _currentUserProfile = null;
    await _auth.signOut();
  }

  /// Translate Firebase Auth / Firestore / Network exceptions into user-friendly messages
  String getFriendlyErrorMessage(dynamic error) {
    final errStr = error.toString();
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-phone-number':
          return 'Please enter a valid 10-digit mobile number.';
        case 'invalid-verification-code':
        case 'invalid-otp':
          return 'Incorrect verification code. Please check and try again.';
        case 'session-expired':
        case 'code-expired':
          return 'Verification code expired. Please request a new OTP.';
        case 'quota-exceeded':
          return 'SMS quota exceeded for today. Please try again later.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait a few minutes before trying again.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'app-not-authorized':
        case 'app-verification-failed':
          return 'App verification failed. Please verify your connection or try again.';
        case 'billing-not-enabled':
          return 'SMS service is temporarily unavailable. Please try again later.';
        case 'captcha-check-failed':
          return 'Security verification failed. Please try again.';
        default:
          return error.message ?? 'Authentication failed. Please try again.';
      }
    }

    if (error is FirebaseException) {
      if (error.code == 'permission-denied') {
        return 'Firestore permission error. Please verify database security rules.';
      }
      if (error.code == 'unavailable') {
        return 'Network connection is slow or unavailable. Please try again.';
      }
      return error.message ?? 'Database error (${error.code}).';
    }

    if (errStr.contains('invalid-verification-code') || errStr.contains('invalid-otp')) {
      return 'Incorrect verification code. Please check and try again.';
    }
    if (errStr.contains('session-expired') || errStr.contains('code-expired')) {
      return 'Verification code expired. Please request a new OTP.';
    }
    if (errStr.contains('too-many-requests')) {
      return 'Too many attempts. Please try again in a few minutes.';
    }
    if (errStr.contains('quota-exceeded')) {
      return 'SMS quota exceeded. Please try again later.';
    }
    if (errStr.contains('network-request-failed') || errStr.contains('SocketException')) {
      return 'Network connection error. Please check your internet connection.';
    }
    if (errStr.contains('permission-denied') || errStr.contains('PERMISSION_DENIED')) {
      return 'Firestore permission error. Please verify database security rules.';
    }

    return errStr.length > 80 ? 'An unexpected error occurred. Please try again.' : errStr;
  }
}
