import '../../core/constants/app_assets.dart';
import '../../core/constants/app_strings.dart';

class OnboardingItem {
  final String asset;
  final String pillText;
  final String badgeText;
  final String title;
  final String description;
  final List<String> tags;

  const OnboardingItem({
    required this.asset,
    required this.pillText,
    required this.badgeText,
    required this.title,
    required this.description,
    this.tags = const [],
  });
}

class OnboardingData {
  OnboardingData._();

  static const List<OnboardingItem> items = [
    OnboardingItem(
      asset: AppAssets.onboardingDog,
      pillText: AppStrings.onboarding1Pill,
      badgeText: AppStrings.onboarding1Badge,
      title: AppStrings.onboarding1Title,
      description: AppStrings.onboarding1Desc,
      tags: ['Organic Supplies', 'Daily Food', 'Toys & Care'],
    ),
    OnboardingItem(
      asset: AppAssets.onboardingVet,
      pillText: AppStrings.onboarding2Pill,
      badgeText: AppStrings.onboarding2Badge,
      title: AppStrings.onboarding2Title,
      description: AppStrings.onboarding2Desc,
      tags: ['Routine Vaccines', 'Telehealth Consults'],
    ),
    OnboardingItem(
      asset: AppAssets.onboardingHug,
      pillText: AppStrings.onboarding3Pill,
      badgeText: AppStrings.onboarding3Badge,
      title: AppStrings.onboarding3Title,
      description: AppStrings.onboarding3Desc,
      tags: ['Store & Provisions', 'Clinic Bookings'],
    ),
  ];
}
