import 'package:flutter/material.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';

class ProfessionalAvatar extends StatelessWidget {
  const ProfessionalAvatar({
    required this.size,
    this.imageUrl,
    this.imageAsset,
    this.borderRadius,
    super.key,
  });

  final double size;
  final String? imageUrl;
  final String? imageAsset;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(size / 2);
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox.square(dimension: size, child: _buildImage()),
    );
  }

  Widget _buildImage() {
    final url = imageUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallback(),
      );
    }

    final asset = imageAsset?.trim();
    if (asset != null && asset.isNotEmpty) {
      return Image.asset(
        asset,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallback(),
      );
    }

    return _fallback();
  }

  Widget _fallback() {
    return const ColoredBox(
      color: AppColors.surfaceMuted,
      child: Center(
        child: Icon(
          Icons.person_rounded,
          color: AppColors.textSecondary,
          size: 38,
        ),
      ),
    );
  }
}
