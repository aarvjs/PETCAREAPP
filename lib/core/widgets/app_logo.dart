import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_assets.dart';
import '../constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isVertical;

  const AppLogo({
    super.key,
    this.size = 72,
    this.showText = true,
    this.isVertical = true,
  });

  @override
  Widget build(BuildContext context) {
    final logoWidget = SvgPicture.asset(
      AppAssets.logoPaw,
      width: size,
      height: size,
    );

    if (!showText) return logoWidget;

    final textWidget = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isVertical ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          'PetCare',
          style: TextStyle(
            color: AppColors.mainText,
            fontSize: size * 0.42,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          'CARE WITH LOVE',
          style: TextStyle(
            color: AppColors.primaryPurple,
            fontSize: size * 0.16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );

    if (isVertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          logoWidget,
          SizedBox(height: size * 0.2),
          textWidget,
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logoWidget,
        const SizedBox(width: 12),
        textWidget,
      ],
    );
  }
}
