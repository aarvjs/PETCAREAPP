/// Centralized compile-time and runtime configuration for the customer application.
///
/// Build or run with a custom Shop ID using:
/// `flutter run --dart-define=SHOP_ID=YOUR_SHOP_ID`
/// `flutter build apk --release --dart-define=SHOP_ID=YOUR_SHOP_ID`
class AppConfig {
  AppConfig._();

  /// Default demo/development Shop ID matching the canonical Healthy Paws Pet Clinic database.
  static const String defaultShopId = 'SHOP-D9E8';

  /// Compile-time configured Shop ID resolved from `--dart-define=SHOP_ID=...`.
  static const String compileTimeShopId = String.fromEnvironment('SHOP_ID');

  /// Runtime override for development testing or shop switching
  static String? _runtimeOverrideShopId;

  /// Effective Shop ID:
  /// - If runtime override is set, use it.
  /// - If compile-time SHOP_ID is provided, use it.
  /// - Otherwise fallback to [defaultShopId] so developers and testers can test without flags.
  static String get shopId {
    if (_runtimeOverrideShopId != null && _runtimeOverrideShopId!.isNotEmpty) {
      return _runtimeOverrideShopId!;
    }
    if (compileTimeShopId.trim().isNotEmpty) {
      return compileTimeShopId.trim();
    }
    return defaultShopId;
  }

  /// Whether a custom shop ID was configured via dart-define
  static bool get hasCompileTimeShopId => compileTimeShopId.trim().isNotEmpty;

  /// Whether current active shopId differs from default
  static bool get isCustomShopId => shopId != defaultShopId;

  /// Allows setting an override for testing
  static void setRuntimeShopId(String? id) {
    _runtimeOverrideShopId = id?.trim();
  }

  /// Reset runtime override
  static void resetRuntimeShopId() {
    _runtimeOverrideShopId = null;
  }

  /// App display name
  static const String appName = 'Healthy Paws';

  /// App version
  static const String appVersion = '1.0.0';
}
