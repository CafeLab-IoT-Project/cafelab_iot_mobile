import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:cafelab_iot_mobile/features/management/presentation/models/inventory_view_models.dart';
import 'package:cafelab_iot_mobile/features/management/presentation/widgets/inventory_common.dart';
import 'package:flutter/material.dart';

class InventoryConsumptionDetailDialog extends StatelessWidget {
  const InventoryConsumptionDetailDialog({
    super.key,
    required this.record,
  });

  final InventoryEntryRecord record;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Detalle de consumo',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3E4234),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                InventoryDetailRow(
                  label: 'Fecha',
                  value: formatInventoryDate(record.entry.dateUsed),
                ),
                InventoryDetailRow(label: 'Lote', value: record.lotLabel),
                InventoryDetailRow(
                  label: 'Producto final',
                  value: record.entry.finalProduct,
                ),
                InventoryDetailRow(
                  label: 'Consumo',
                  value: '${formatInventoryWeight(record.entry.quantityUsed)} kg',
                ),
                InventoryDetailRow(
                  label: 'Tipo de cafe',
                  value: record.coffeeTypeLabel,
                ),
                InventoryDetailRow(
                  label: 'Stock actual',
                  value: '${formatInventoryWeight(record.currentLotStock)} kg',
                ),
                InventoryDetailRow(label: 'Estado', value: record.statusLabel),
                const SizedBox(height: 8),
                AuthPrimaryButton(
                  label: 'Cerrar',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
