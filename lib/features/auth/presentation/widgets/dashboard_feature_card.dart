import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/dashboard_feature_item.dart';
import 'package:flutter/material.dart';

class DashboardFeatureCard extends StatelessWidget {
  const DashboardFeatureCard({
    super.key,
    required this.feature,
    this.onTap,
  });

  final DashboardFeatureItem feature;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${feature.title} — próximamente'),
                ),
              );
            },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 4),
                child: Center(
                  child: Image.asset(
                    feature.imageAsset,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      color: AuthColors.inputBackground,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 12),
              child: Text(
                feature.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF414535),
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
