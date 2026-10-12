import '../../core/constants/app_assets.dart';
import '../../core/constants/app_strings.dart';

class OnboardingItem {
  final String asset;
  final String title;
  final String description;

  const OnboardingItem({
    required this.asset,
    required this.title,
    required this.description,
  });
}

class OnboardingData {
  OnboardingData._();

  static const List<OnboardingItem> items = [
    OnboardingItem(
      asset: AppAssets.onboardingDog,
      title: AppStrings.onboarding1Title,
      description: AppStrings.onboarding1Desc,
    ),
    OnboardingItem(
      asset: AppAssets.onboardingVet,
      title: AppStrings.onboarding2Title,
      description: AppStrings.onboarding2Desc,
    ),
    OnboardingItem(
      asset: AppAssets.onboardingHug,
      title: AppStrings.onboarding3Title,
      description: AppStrings.onboarding3Desc,
    ),
  ];
}
