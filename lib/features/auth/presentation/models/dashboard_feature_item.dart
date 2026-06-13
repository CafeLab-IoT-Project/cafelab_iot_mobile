import 'package:cafelab_iot_mobile/features/auth/presentation/models/dashboard_feature_id.dart';

class DashboardFeatureItem {
  const DashboardFeatureItem({
    required this.id,
    required this.title,
    required this.imageAsset,
  });

  final DashboardFeatureId id;
  final String title;
  final String imageAsset;
}
