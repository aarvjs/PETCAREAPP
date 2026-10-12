import 'package:flutter_test/flutter_test.dart';
import 'package:pet_care/core/models/user_model.dart';
import 'package:pet_care/core/services/auth_service.dart';

void main() {
  group('AuthService - Phone Formatting & Masking Tests', () {
    test('Formats 10-digit Indian numbers with +91', () {
      final formatted = AuthService.instance.formatPhoneNumber('9876543210');
      expect(formatted, '+919876543210');
    });

    test('Formats 11-digit number starting with 0', () {
      final formatted = AuthService.instance.formatPhoneNumber('09876543210');
      expect(formatted, '+919876543210');
    });

    test('Formats 12-digit number starting with 91', () {
      final formatted = AuthService.instance.formatPhoneNumber('919876543210');
      expect(formatted, '+919876543210');
    });

    test('Preserves already formatted +91 number', () {
      final formatted = AuthService.instance.formatPhoneNumber('+919876543210');
      expect(formatted, '+919876543210');
    });

    test('Correctly masks Indian mobile number for OTP screen', () {
      final masked = AuthService.instance.maskPhoneNumber('9876543210');
      expect(masked, '+91 98****3210');
    });

    test('Correctly masks +91 formatted number', () {
      final masked = AuthService.instance.maskPhoneNumber('+919876543210');
      expect(masked, '+91 98****3210');
    });
  });

  group('AuthService - Role Protection Tests', () {
    test('Identifies privileged administrative roles correctly', () {
      expect(AuthService.instance.isPrivilegedRole('admin'), isTrue);
      expect(AuthService.instance.isPrivilegedRole('doctor'), isTrue);
      expect(AuthService.instance.isPrivilegedRole('super_admin'), isTrue);
      expect(AuthService.instance.isPrivilegedRole('business'), isTrue);
    });

    test('Identifies non-privileged customer roles correctly', () {
      expect(AuthService.instance.isPrivilegedRole('customer'), isFalse);
      expect(AuthService.instance.isPrivilegedRole(null), isFalse);
      expect(AuthService.instance.isPrivilegedRole(''), isFalse);
    });
  });

  group('UserModel Serialization Tests', () {
    test('Deserializes from Firestore map with defaults', () {
      final map = {
        'uid': 'test_uid_123',
        'phoneNumber': '+919876543210',
        'name': 'Rahul Sharma',
        'role': 'customer',
        'profileCompleted': true,
        'city': 'Kanpur',
      };

      final model = UserModel.fromMap(map, 'test_uid_123');
      expect(model.uid, 'test_uid_123');
      expect(model.phoneNumber, '+919876543210');
      expect(model.name, 'Rahul Sharma');
      expect(model.role, 'customer');
      expect(model.profileCompleted, isTrue);
      expect(model.city, 'Kanpur');
    });

    test('Serializes to map preserving customer fields and role', () {
      final model = UserModel(
        uid: 'test_uid_456',
        phoneNumber: '+919876543210',
        name: 'Priya',
        role: 'customer',
        profileCompleted: false,
        profileSkipped: true,
      );

      final map = model.toMap();
      expect(map['uid'], 'test_uid_456');
      expect(map['phoneNumber'], '+919876543210');
      expect(map['role'], 'customer');
      expect(map['name'], 'Priya');
      expect(map['profileCompleted'], isFalse);
      expect(map['profileSkipped'], isTrue);
    });
  });

  group('AuthService - Friendly Error Messages & Local Profile Tests', () {
    test('Translates Firestore permission error accurately without verification text', () {
      final msg = AuthService.instance.getFriendlyErrorMessage('PERMISSION_DENIED: Missing or insufficient permissions.');
      expect(msg, contains('Firestore permission error'));
      expect(msg, isNot(contains('verification')));
    });

    test('Generic long error message fallback does not mention verification', () {
      final msg = AuthService.instance.getFriendlyErrorMessage(
        'Some generic very long internal system error string that exceeds eighty characters in length to test fallback message',
      );
      expect(msg, contains('An unexpected error occurred'));
      expect(msg, isNot(contains('verification')));
    });

    test('updateLocalProfile caches profile state in memory without throwing', () {
      AuthService.instance.updateLocalProfile(
        name: 'Arvind',
        profileCompleted: true,
        profileSkipped: false,
      );
      expect(AuthService.instance.currentUserProfile?.name, 'Arvind');
      expect(AuthService.instance.currentUserProfile?.profileCompleted, isTrue);
    });
  });
}
