import 'package:cafelab_iot_mobile/features/cost_management/domain/models/production_cost_record_status.dart';
import 'package:cafelab_iot_mobile/features/cost_management/presentation/constants/cost_management_colors.dart';
import 'package:flutter/material.dart';

class CostRecordStatusBadge extends StatelessWidget {
  const CostRecordStatusBadge({
    super.key,
    required this.status,
  });

  final ProductionCostRecordStatus status;

  @override
  Widget build(BuildContext context) {
    final isAnnulled = status == ProductionCostRecordStatus.anulado;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAnnulled
            ? CostManagementColors.annulledBadgeBg
            : CostManagementColors.registeredBadgeBg,
        border: Border.all(
          color: isAnnulled
              ? CostManagementColors.annulledBadgeBorder
              : CostManagementColors.registeredBadgeBorder,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayLabel.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
          color: isAnnulled
              ? CostManagementColors.annulledBadgeText
              : CostManagementColors.registeredBadgeText,
        ),
      ),
    );
  }
}
