import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Renders either a Firebase Storage network URL or local asset path safely.
/// Includes graceful loading skeleton and fallback icon.
class AppNetworkImage extends StatelessWidget {
  final String urlOrAsset;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const AppNetworkImage({
    super.key,
    String? urlOrAsset,
    String? imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  }) : urlOrAsset = imageUrl ?? urlOrAsset ?? '';

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (urlOrAsset.startsWith('http://') || urlOrAsset.startsWith('https://')) {
      imageWidget = Image.network(
        urlOrAsset,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height,
            color: AppColors.surfaceMuted,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _placeholder();
        },
      );
    } else if (urlOrAsset.isNotEmpty) {
      imageWidget = Image.asset(
        urlOrAsset,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return _placeholder();
        },
      );
    } else {
      imageWidget = _placeholder();
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceMuted,
      child: const Center(
        child: Icon(
          Icons.pets_rounded,
          size: 28,
          color: AppColors.mutedText,
        ),
      ),
    );
  }
}
