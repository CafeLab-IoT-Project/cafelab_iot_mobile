import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:cafelab_iot_mobile/features/management/presentation/models/inventory_view_models.dart';
import 'package:cafelab_iot_mobile/features/management/presentation/widgets/inventory_common.dart';
import 'package:flutter/material.dart';

class InventorySummaryCard extends StatelessWidget {
  const InventorySummaryCard({
    super.key,
    required this.grainType,
    required this.summary,
    required this.availableCoffeeTypes,
    required this.selectedCoffeeType,
    required this.onCoffeeTypeChanged,
    required this.onRegisterPressed,
    this.isRegisterEnabled = true,
    this.isLoading = false,
  });

  final InventoryGrainType grainType;
  final InventorySummaryData summary;
  final List<String> availableCoffeeTypes;
  final String? selectedCoffeeType;
  final ValueChanged<String?> onCoffeeTypeChanged;
  final VoidCallback onRegisterPressed;
  final bool isRegisterEnabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final hasCoffeeTypes = availableCoffeeTypes.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AuthColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            grainType.sectionTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Tipo de cafe',
            style: TextStyle(
              color: Color(0xFFF2EEE7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (hasCoffeeTypes)
            DropdownButtonFormField<String>(
              initialValue: selectedCoffeeType,
              items: availableCoffeeTypes
                  .map(
                    (type) => DropdownMenuItem<String>(
                      value: type,
                      child: Text(type, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: onCoffeeTypeChanged,
              decoration: inventoryRoundedFieldDecoration('Tipo de cafe'),
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              borderRadius: BorderRadius.circular(18),
              dropdownColor: Colors.white,
            )
          else
            InputDecorator(
              decoration: inventoryRoundedFieldDecoration('Tipo de cafe'),
              child: const Text(
                'Sin tipos disponibles',
                style: TextStyle(
                  color: Color(0xFF6D6D6D),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 18),
          _SummaryRow(
            label: 'Stock total (todos los tipos)',
            value: '${formatInventoryWeight(summary.totalStock)} kg',
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            label: 'Tipo seleccionado',
            value: summary.selectedCoffeeType,
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            label: 'Stock del tipo seleccionado',
            value: '${formatInventoryWeight(summary.selectedTypeStock)} kg',
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            label: 'Lotes activos del tipo seleccionado',
            value: '${summary.activeLotsCount}',
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            label: 'Proveedores del tipo seleccionado',
            value: '${summary.suppliersCount}',
          ),
          const SizedBox(height: 18),
          AuthPrimaryButton(
            label: 'Registrar consumo',
            isLoading: isLoading,
            onPressed: isRegisterEnabled ? onRegisterPressed : null,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFF2EEE7),
              fontSize: 15,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
