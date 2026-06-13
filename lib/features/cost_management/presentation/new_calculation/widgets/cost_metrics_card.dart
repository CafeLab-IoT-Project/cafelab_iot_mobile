import 'package:cafelab_iot_mobile/features/cost_management/presentation/constants/cost_management_colors.dart';
import 'package:flutter/material.dart';

class CostMetricsCard extends StatelessWidget {
  const CostMetricsCard({
    super.key,
    required this.costPerKg,
    required this.potentialMargin,
    required this.suggestedPrice,
    required this.currencySymbol,
  });

  final double costPerKg;
  final double potentialMargin;
  final double suggestedPrice;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: CostManagementColors.headerGreen),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _MetricRow(
            label: 'Costo por Kilogramo',
            value: '$currencySymbol ${costPerKg.toStringAsFixed(2)}',
          ),
          const Divider(height: 20),
          _MetricRow(
            label: 'Margen Potencial',
            value: '${potentialMargin.toStringAsFixed(1)}%',
          ),
          const Divider(height: 20),
          _MetricRow(
            label: 'Precio Sugerido',
            value: '$currencySymbol ${suggestedPrice.toStringAsFixed(2)} / kg',
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ],
    );
  }
}
